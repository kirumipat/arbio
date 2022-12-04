#!/bin/bash
#arch install script ARCH+BTRFS+GNOME+SNAPSHOT+SOFT
# Создание разделов диска
lsblk
read -p "Disk =  " AddDisk
DN1=$AddDisk"p1"
DN2=$AddDisk"p2"
echo -e "n\np\n1\n\n+1024M\nn\np\n2\n\n\na\n1\nw\n" | fdisk /dev/$AddDisk
#Форматирование разделов
mkfs.fat -F32 -n BOOT /dev/$DN1
mkfs.btrfs -f -L ROOT /dev/$DN2
#mkfs.btrfs -f -L SHARA -m raid5 -d raid5 /dev/sda /dev/sdb /dev/sdc /dev/sdd
#Монтируем раздел
mount /dev/$DN2 /mnt
#Создаём BTRFS тома
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@root
btrfs su cr /mnt/@var
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@snapshots
#Отмантируем раздел
umount /dev/$DN2
#Монтируем тома в разделы со сжатием и свойствами
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@ /dev/$DN2  /mnt/
mkdir -p /mnt/{boot/EFI,home,root,var,opt,tmp,.snapshots,shara}
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@home /dev/$DN2  /mnt/home
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@root /dev/$DN2  /mnt/root
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@var /dev/$DN2 /mnt/var
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@opt /dev/$DN2  /mnt/opt
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@snapshots /dev/$DN2  /mnt/.snapshots
mount -o noatime,compress=zstd:2,ssd,space_cache=v2,discard=async,subvol=@tmp /dev/$DN2  /mnt/tmp
#mount /dev/sda  /mnt/shara
mount /dev/$DN1 /mnt/boot/
#Установка минимального набора
sed 's/Architecture = auto/Architecture = auto \n ILoveCandy/g' -i /etc/pacman.conf
sed 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' -i /etc/pacman.conf
sed 's/#Color/Color/g' -i /etc/pacman.conf
pacman -Syy --noconfirm
reflector --latest 15 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel btrfs-progs linux-zen linux-zen-headers linux-zen-docs linux-firmware grub grub-btrfs os-prober efibootmgr dosfstools mtools reflector
#Генерация fstab
genfstab -U -p /mnt >> /mnt/etc/fstab
#копируем вторую часть скрипта в новую систему
cp /root/arbio/in_mini.sh /mnt/
chmod +x /mnt/in_mini.sh
#переходим в новую систему и там запускаем вторую часть /in.sh
arch-chroot /mnt sh -c /in_mini.sh

