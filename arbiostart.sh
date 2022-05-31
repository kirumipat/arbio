#arch install script ARCH+BTRFS+GNOME+SNAPSHOT+SOFT
#!/bin/bash
# Создание разделов диска
echo -e "n\np\n1\n\n+1024M\nn\np\n2\n\n\na\n1\nw\n" | fdisk /dev/sda
#Форматирование разделов
mkfs.fat -F32 -n BOOT /dev/sda1
mkfs.btrfs -f -L ROOT /dev/sda2
#Монтируем раздел
mount /dev/sda2 /mnt
#Создаём BTRFS тома
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@root
btrfs su cr /mnt/@var
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@.snapshots
#Отмантируем раздел
umount /dev/sda2
#Монтируем тома в разделы со сжатием и свойствами
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@ /dev/sda2  /mnt/
mkdir  /mnt/{boot,home,root,var,opt,tmp,.snapshots}
mkdir /mnt/boot/EFI
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@home /dev/sda2  /mnt/home
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@root /dev/sda2  /mnt/root
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@var /dev/sda2  /mnt/var
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@opt /dev/sda2  /mnt/opt
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@.snapshots /dev/sda2  /mnt/.snapshots
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@tmp /dev/sda2  /mnt/tmp
mount dev/sda1 /mnt/boot/EFI
#Разкоментрируем русскую локаль/Генерируем локаль/Применяем локаль
sed '/ru_RU.UTF-8 UTF-8/s/^#//' -i /etc/locale.gen
locale-gen
localectl set-locale ru_RU.UTF-8
#Установка минимального набора
pacman -Syy --noconfirm
pacstrap /mnt base base-devel btrfs-progs intel-ucode linux-zen linux-zen-headers linux-zen-docs linux-firmware grub os-prober networkmanager efibootmgr dosfstools mtools
#Генерация fstab
genfstab -U -p /mnt >> /mnt/etc/fstab
#Разкоментрируем русскую локаль
sed '/ru_RU.UTF-8 UTF-8/s/^#//' -i /mnt/etc/locale.gen
#установка шрифта для консоли
echo "KEYMAP=ru" >> /mnt/etc/vconsole.conf
echo "FONT=cyr-sun16 " >> /mnt/etc/vconsole.conf
#Установка таймзоны
ln -s /usr/share/zoneinfo/Europe/Kiev /mnt/etc/localtime
#Имя hostname
echo "localhost" >> /mnt/etc/hostname
#права судо для группы wheel
sed '/%wheel ALL=(ALL) All/s/^#//' -i /mnt/etc/sudoers
#копируем фторую часть скрипта в новую систему
cp /root/arbio/in.sh /mnt/home/
chmod +x /mnt/home/in.sh
#переходим вновую систему и там запускаем вторую часть /home/in.sh
arch-chroot /mnt


