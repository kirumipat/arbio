#!/bin/bash
echo -e "n\np\n1\n\n+512M\nn\np\n2\n\n\na\n1\nw\n" | fdisk /dev/sda
mkfs.fat -F32 -n BOOT /dev/sda1
mkfs.btrfs -f -L ROOT /dev/sda2
mount /dev/sda2 /mnt
cd /mnt
btrfs su cr @
btrfs su cr @home
btrfs su cr @root
btrfs su cr @srv
btrfs su cr @cashe
btrfs su cr @log
btrfs su cr @tmp
umount /dev/sda2
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@ /dev/sda2  /mnt
mkdir  /mnt/{boot,home,root,srv,var}
mkdir /mnt/boot/EFI
cd /mnt/var
mkdir {cashe,log,tmp}
cd ../
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@home /dev/sda2  /mnt/home
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@root /dev/sda2  /mnt/root
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@srv /dev/sda2  /mnt/srv
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@cashe /dev/sda2  /mnt/var/cashe
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@log /dev/sda2  /mnt/var/log
mount -o noatime,compress=zstd,ssd,space_cache=v2,discard=async,subvol=@tmp /dev/sda2  /mnt/var/tmp
mount dev/sda1 /mnt/boot/EFI
pacman -Syy
pacstrap /mnt base base-devel btrfs-progs git  linux-zen linux-zen-headers  linux-firmware nano  wget curl   grub os-prober networkmanager efibootmgr dosfstools mtools go xorg gnome
genfstab -U -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt
pacman -Syy
echo "LANG=ru_RU.UTF-8" >> /etc/locale.gen
echo "KEYMAP=ru /n FONT=cyr-sun16 " >> /etc/vconsole.conf
locale-gen
ln -s /usr/share/zoneinfo/Europe/Kiev /etc/localtime
echo "localhost" >> /etc/hostname
echo "%wheel ALL=(ALL) All" >> /etc/sudoers
systemctl enable NetworkManager gdm
mkinitcpio -p linux-zen
grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg