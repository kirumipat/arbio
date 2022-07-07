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
sed 's/# %wheel ALL=(ALL:ALL) ALL/ %wheel ALL=(ALL:ALL) ALL/g' -i /etc/sudoers
locale-gen
localectl set-locale ru_RU.UTF-8
hwclock --systohc
#root пароль и добавление пользователя
echo 'root pass'
passwd
read -p "Add User : " username
useradd -m -g users -G wheel -s /bin/bash $username
echo 'User pass'
passwd $username
#настройка mkinit
sed 's/BINARIES=()/BINARIES=(btrfs)/g' -i /etc/mkinitcpio.conf
sed 's/#COMPRESSION="zstd"/COMPRESSION="zstd"/g' -i /etc/mkinitcpio.conf
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
sed 's/Architecture = auto/Architecture = auto \n ILoveCandy/g' -i /etc/pacman.conf
sed 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' -i /etc/pacman.conf
sed 's/#Color/Color/g' -i /etc/pacman.conf
#Ядро и основные утилиты
pacman -Sy --noconfirm mkinitcpio-firmware linux-lqx linux-lqx-headers linux-lqx-docs nano wget curl git reflector
#Загрузка файловая система снапшоты
pacman -Sy --noconfirm grub grub-btrfs os-prober efibootmgr dosfstools mtools timeshift grub-customizer ntfs-3g
#Сеть и блютуз
pacman -Sy --noconfirm networkmanager wpa_supplicant dialog bluez bluez-utils
#Графическое окружение
pacman -Sy --noconfirm xorg gnome gnome-shell-extensions gnome-tweaks network-manager-applet
#Програмировани 
pacman -Sy --noconfirm go vscodium pycharm-community-edition intellij-idea-community-edition
#Мультимедиа 
pacman -Sy --noconfirm deadbeef haruna gimp ffmpegthumbs mediainfo-gui handbrake 
#Нужный софт
pacman -Sy --noconfirm htop stacer qbittorrent-nox google-chrome xdg-user-dirs p7zip unrar neofetch kdiskmark cabextract
#Для игр
pacman -Sy --noconfirm mesa lib32-mesa mesa-utils lib32-mesa-utils opencl-mesa lib32-opencl-mesa vulcan-radeon lib32-vulcan-radeon gamemode steam protonup-qt gamescope
#Повышение производительности
pacman -Sy --noconfirm ananicy-cpp ananicy-rules-git 
# Шрифты орфография
pacman -Sy --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-nerd-fonts-symbols hunspell
#Настройк Grub загрузчика системы
grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
#Отключение заплаток intel
sed 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet rootfstype=btrfs mitigations=off nowatchdog"/g' -i /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
#Добавление сервисов в автоpагрузку
systemctl enable NetworkManager gdm bluetooth ananicy-cpp
systemctl mask NetworkManager-wait-online.service

echo "Enter reboot -now"
rm /in.sh
exit
