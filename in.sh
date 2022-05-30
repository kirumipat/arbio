grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
locale-gen
localectl set-locale ru_RU.UTF-8
hwclock --systohc
echo "root:123" | chpasswd


chmod +x ./addrepo.sh
./addrepo.sh

pacman -Sy --noconfirm mkinitcpio-firmware linux-lqx linux-lqx-headers linux-lqx-docs grub-btrfs network-manager-applet reflector wpa_supplicant dialog bluez bluez-utils ananicy-cpp ananicy-rules-git stacer gamemode lib32-gamemode timeshift gnome-shell-extensions grub-customizer
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager gdm bluetooth ananicy-cpp
systemctl mask NetworkManager-wait-online.service

