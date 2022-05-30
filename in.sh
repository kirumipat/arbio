grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /mnt/boot/grub/grub.cfg
locale-gen
systemctl enable NetworkManager gdm