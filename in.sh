#Разкоментрируем русскую локаль
sed '/ru_RU.UTF-8 UTF-8/s/^#//' -i /etc/locale.gen
#установка шрифта для консоли
echo "KEYMAP=ru" >> /etc/vconsole.conf
echo "FONT=cyr-sun16 " >> /etc/vconsole.conf
#Установка таймзоны
ln -s /usr/share/zoneinfo/Europe/Kiev /etc/localtime
#Имя hostname
echo "localhost" >> /mnt/etc/hostname
#права судо для группы wheel
sed '/%wheel ALL=(ALL) All/s/^#//' -i /etc/sudoers
locale-gen
localectl set-locale ru_RU.UTF-8
hwclock --systohc
echo "root:123" | chpasswd
#Добавляем репозитории
pacman -Syy --noconfirm
#chaotic-aur
pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
#liquorix
pacman-key --recv-key 9AE4078033F8024D --keyserver hkps://keyserver.ubuntu.com
pacman-key --lsign-key 9AE4078033F8024D
echo "[liquorix]" >> /etc/pacman.conf
echo "Server = https://liquorix.net/archlinux/liquorix/x86_64/" >> /etc/pacman.conf
#multilib
echo "[multilib]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
#Устанавливаем софт
sed '/ParallelDownloads = 5/s/^#//' -i /etc/pacman.conf
#Ядро и основные утилиты
pacman -Sy --noconfirm mkinitcpio-firmware linux-lqx linux-lqx-headers linux-lqx-docs nano wget curl git reflector
#Загрузка файловая система снапшоты
pacman -Sy --noconfirm grub-btrfs grub os-prober efibootmgr dosfstools mtools timeshift grub-customizer
#Сеть и блютуз
pacman -Sy --noconfirm networkmanager network-manager-applet wpa_supplicant dialog bluez bluez-utils
#Графическое окружение
pacman -Sy --noconfirm xorg gnome gnome-shell-extensions 
#Нужный софт
pacman -Sy --noconfirm stacer go
#Повышение производительности
pacman -Sy --noconfirm ananicy-cpp ananicy-rules-git gamemode lib32-gamemode 
#Настройк Grub загрузчика системы
grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
#Добавление сервисов в автоpагрузку
systemctl enable NetworkManager gdm bluetooth ananicy-cpp
systemctl mask NetworkManager-wait-online.service

rm /in.sh
exit
