#test arch install
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

sed '/ru_RU.UTF-8 UTF-8/s/^#//' -i /etc/locale.gen
locale-gen
pacman -Syy --noconfirm

pacman -Syy --noconfirm
pacstrap /mnt base base-devel btrfs-progs linux-zen linux-zen-headers linux-zen-docs linux-firmware grub os-prober networkmanager efibootmgr dosfstools mtools go xorg gnome nano wget curl git

genfstab -U -p /mnt >> /mnt/etc/fstab
sed '/ru_RU.UTF-8 UTF-8/s/^#//' -i /mnt/etc/locale.gen
echo "KEYMAP=ru" >> /mnt/etc/vconsole.conf
echo "FONT=cyr-sun16 " >> /mnt/etc/vconsole.conf
ln -s /usr/share/zoneinfo/Europe/Kiev /mnt/etc/localtime
echo "localhost" >> /mnt/etc/hostname
sed '/%wheel ALL=(ALL) All/s/^#//' -i /mnt/etc/sudoers

cp /arbio/in.sh /mnt/home
arch-chroot /mnt


