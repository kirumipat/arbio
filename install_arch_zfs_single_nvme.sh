#!/bin/bash

# Exit on error
set -e

# Параметры конфигурации
DISK="/dev/nvme0n1"        # Диск для установки
USERNAME="skid"            # Имя пользователя
PASSWORD="123"             # Пароль для пользователя
SWAP_SIZE="8G"             # Размер своп-объема
ARC_SIZE="24G"             # Размер ARC кеша в гигабайтах
EFI_SIZE="512M"            # Размер EFI-раздела

# Конвертация ARC_SIZE и SWAP_SIZE в байты
ARC_SIZE_BYTES=$((ARC_SIZE * 1024 * 1024 * 1024))  # Преобразование в байты
ARC_MIN_SIZE_BYTES=$((8 * 1024 * 1024 * 1024))      # 8GB для минимального ARC в байтах

# Установка необходимых пакетов
echo "Установка необходимых пакетов"
pacman -Sy --noconfirm zfs-utils archzfs linux-headers

# Установка часового пояса
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc

# Обновление системного времени
timedatectl set-ntp true

# Подготовка диска
echo "Разделение диска"
sgdisk --zap-all $DISK
sgdisk -n 1:0:+${EFI_SIZE} -t 1:ef00 $DISK  # Создание EFI раздела
sgdisk -n 2:0:0 -t 2:bf00 $DISK             # Создание основного раздела для ZFS

# Форматируем EFI-раздел
mkfs.vfat -F32 ${DISK}-part1

# Создание ZFS пула
echo "Создание ZFS пула с оптимизированной конфигурацией"
zpool create -f -o ashift=12 \
  -O acltype=posixacl \
  -O xattr=sa \
  -O relatime=on \
  -O dnodesize=auto \
  -O compression=lz4 \
  -O normalization=formD \
  -O atime=off \
  -O logbias=latency \
  -O primarycache=all \
  -O secondarycache=all \
  -O sync=disabled \
  -O devices=off \
  rpool ${DISK}-part2  # Основной раздел для ZFS

# Настройка ZFS для системы
echo "Настройка ZFS datasets"
zfs create -o mountpoint=none rpool/ROOT
zfs create -o mountpoint=/ rpool/ROOT/arch
zpool set bootfs=rpool/ROOT/arch rpool

# Создание своп-объема в ZFS
echo "Создание ZFS swap"
zfs create -V $SWAP_SIZE -b 4096 -o compression=off -o primarycache=metadata rpool/swap
mkswap /dev/zvol/rpool/swap
swapon /dev/zvol/rpool/swap

# Монтируем корень и создаем необходимые каталоги
mount -t zfs rpool/ROOT/arch /mnt
mkdir /mnt/{boot,home,var,opt,srv,usr,tmp}

# Монтируем EFI-раздел
mount ${DISK}-part1 /mnt/boot

# Установка базовой системы Arch Linux
echo "Установка Arch Linux"
pacstrap /mnt base linux linux-firmware grub os-prober gnome gnome-extra networkmanager blueman

# Настройка системы (fstab, chroot)
echo "Генерация fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# Переключение в систему
arch-chroot /mnt /bin/bash <<EOF

# Установка ZFS в chroot
echo "Установка ZFS в chroot"
pacman -Sy --noconfirm zfs-linux

# Настройка GRUB для поддержки ZFS
echo "Установка и настройка GRUB"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Настройка конфигурации GRUB для ZFS
cat <<EOL > /etc/default/grub
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX="zfs=rpool/ROOT/arch rw"
GRUB_PRELOAD_MODULES="zfs"
GRUB_TERMINAL_OUTPUT=console
GRUB_DISABLE_SUBMENU=true
GRUB_DISABLE_RECOVERY=true
GRUB_ENABLE_CRYPTODISK=n
EOL

# Генерация конфигурации GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Настройка локали
echo "Настройка локали"
echo "ru_RU.UTF-8 UTF-8" > /etc/locale.gen  # Русский язык
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen  # Английский язык
locale-gen
echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo "KEYMAP=us,ru" > /etc/vconsole.conf  # Обе раскладки клавиатуры
echo "archzfs" > /etc/hostname

# Создание пользователя
echo "Создание пользователя $USERNAME"
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

# Настройка sudo для пользователя
echo "Настройка sudo для пользователя $USERNAME"
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Настройка параметров ARC кеша
echo "Настройка ARC кеша"
echo "options zfs zfs_arc_max=$ARC_SIZE_BYTES" > /etc/modprobe.d/zfs.conf  # Задаем размер ARC в байтах
echo "options zfs zfs_arc_min=$ARC_MIN_SIZE_BYTES" >> /etc/modprobe.d/zfs.conf  # Задаем минимальный размер ARC

# Включение автоматического запуска GNOME
systemctl enable gdm.service

# Включение NetworkManager и Bluetooth для автозапуска
systemctl enable NetworkManager.service
systemctl enable bluetooth.service

EOF

# Завершение
echo "Установка завершена! Пожалуйста, перезагрузите."
