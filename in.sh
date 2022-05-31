locale-gen
localectl set-locale ru_RU.UTF-8
hwclock --systohc
echo "root:123" | chpasswd

pacman -Syy --noconfirm

pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf

pacman-key --recv-key 9AE4078033F8024D --keyserver hkps://keyserver.ubuntu.com
pacman-key --lsign-key 9AE4078033F8024D
echo "[liquorix]" >> /etc/pacman.conf
echo "Server = https://liquorix.net/archlinux/liquorix/x86_64/" >> /etc/pacman.conf

echo "[multilib]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

pacman -Sy --noconfirm mkinitcpio-firmware linux-lqx linux-lqx-headers linux-lqx-docs grub-btrfs go xorg gnome gnome-shell-extensions nano wget curl git network-manager-applet reflector wpa_supplicant dialog bluez bluez-utils ananicy-cpp ananicy-rules-git stacer gamemode lib32-gamemode timeshift gnome-shell-extensions grub-customizer

grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager gdm bluetooth ananicy-cpp
systemctl mask NetworkManager-wait-online.service

