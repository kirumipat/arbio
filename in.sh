grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
locale-gen
systemctl enable NetworkManager gdm
echo "root:123" | chpasswd

chmod +x ./addrepo.sh
./addrepo.sh

pacman -Sy --noconfirm mkinitcpio-firmware linux-lqx linux-lqx-headers linux-lqx-docs 