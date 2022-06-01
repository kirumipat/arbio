#!/bin/bash
#arch install script ARCH+BTRFS+GNOME+SNAPSHOT+SOFT
# Создание разделов диска
lsblk
read -p "Disk =  " AddDisk
echo -e "n\np\n1\n\n+1024M\nn\np\n2\n\n\na\n1\nw\n" | fdisk /dev/$AddDisk
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
btrfs su cr /mnt/@snapshots
#Отмантируем раздел
umount /dev/sda2
#Монтируем тома в разделы со сжатием и свойствами
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@ /dev/sda2  /mnt/
mkdir -p /mnt/{boot/EFI,home,root,var,opt,tmp,.snapshots}
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@home /dev/sda2  /mnt/home
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@root /dev/sda2  /mnt/root
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@var /dev/sda2  /mnt/var
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@opt /dev/sda2  /mnt/opt
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@snapshots /dev/sda2  /mnt/.snapshots
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@tmp /dev/sda2  /mnt/tmp
mount dev/sda1 /mnt/boot/EFI
#Установка минимального набора
sed 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' -i /etc/pacman.conf
pacman -Syy --noconfirm
pacstrap /mnt base base-devel btrfs-progs intel-ucode linux-zen linux-zen-headers linux-zen-docs linux-firmware
#Генерация fstab
genfstab -U -p /mnt >> /mnt/etc/fstab
#копируем фторую часть скрипта в новую систему
cp /root/arbio/in.sh /mnt/
chmod +x /mnt/in.sh
#переходим в новую систему и там запускаем вторую часть /in.sh
arch-chroot /mnt sh -c /in.sh

