grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
locale-gen
localectl set-locale ru_RU.UTF-8
localectl set-x11-keymap --no-convert us,ru pc105 "" grp:alt_shift_toggle

echo "root:123" | chpasswd
hwclock --systohc

chmod +x ./addrepo.sh
./addrepo.sh

pacman -Sy --noconfirm mkinitcpio-firmware linux-lqx linux-lqx-headers linux-lqx-docs  man-pages-ru grub-btrfs network-manager-applet reflector wpa_supplicant dialog bluez bluez-utils

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager gdm bluetooth 


exit 
cd ../
umount -a 
reboot now 