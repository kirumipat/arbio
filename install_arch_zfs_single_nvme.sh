!#/bin/bash
DISK="/dev/nvme0n1"
USERNAME="skid"
PASSWORD="123"
SWAP_SIZE="8G"
ARC_SIZE="12G"
EFI_SIZE="512M"
ARC_SIZE_BYTES=$((ARC_SIZE * 1024 * 1024 * 1024))
ARC_MIN_SIZE_BYTES=$((8 * 1024 * 1024 * 1024))
pacman -Sy --noconfirm zfs-utils archzfs linux-headers
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
timedatectl set-ntp true
sgdisk --zap-all $DISK
sgdisk -n 1:0:+${EFI_SIZE} -t 1:ef00 $DISK
sgdisk -n 2:0:0 -t 2:bf00 $DISK
mkfs.vfat -F32 ${DISK}-part1
zpool create -f -o ashift=12 \
  -O acltype=posixacl \
  -O xattr=sa \
  -O relatime=on \
  -O dnodesize=auto \
  -O compression=lz4 \
  -O normalization=formD \
  -O atime=off \
  -O logbias=latency \
  -O primarycache=all \
  -O secondarycache=all \
  -O sync=disabled \
  -O devices=off \
  rpool ${DISK}-part2
zfs create -o mountpoint=none rpool/ROOT
zfs create -o mountpoint=/ rpool/ROOT/arch
zpool set bootfs=rpool/ROOT/arch rpool
zfs create -V $SWAP_SIZE -b 4096 -o compression=off -o primarycache=metadata rpool/swap
mkswap /dev/zvol/rpool/swap
swapon /dev/zvol/rpool/swap
mount -t zfs rpool/ROOT/arch /mnt
mkdir /mnt/{boot,home,var,opt,srv,usr,tmp}
mount ${DISK}-part1 /mnt/boot
pacstrap /mnt base linux linux-firmware grub os-prober gnome gnome-extra networkmanager blueman
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash <<EOF
pacman -Sy --noconfirm zfs-linux
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
cat <<EOL > /etc/default/grub
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX="zfs=rpool/ROOT/arch rw"
GRUB_PRELOAD_MODULES="zfs"
GRUB_TERMINAL_OUTPUT=console
GRUB_DISABLE_SUBMENU=true
GRUB_DISABLE_RECOVERY=true
GRUB_ENABLE_CRYPTODISK=n
EOL
grub-mkconfig -o /boot/grub/grub.cfg
echo "ru_RU.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo "KEYMAP=us,ru" > /etc/vconsole.conf
echo "archzfs" > /etc/hostname
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "options zfs zfs_arc_max=$ARC_SIZE_BYTES" > /etc/modprobe.d/zfs.conf  # Задаем размер ARC в байтах
echo "options zfs zfs_arc_min=$ARC_MIN_SIZE_BYTES" >> /etc/modprobe.d/zfs.conf  # Задаем минимальный размер ARC
systemctl enable gdm.service
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
EOF
