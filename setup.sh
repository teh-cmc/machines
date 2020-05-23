#!/usr/bin/env bash

set -eux

# Merely a guideline: tweak as needed.
#
# Default: unencrypted /boot with LVM-on-LUKS swap/os/data setup.

MACHINE=cmclaptop-I
DISK=/dev/nvme0n1

LVM_SWAP_SIZE=8G
LVM_OS_SIZE=64G

timedatectl set-ntp true

parted -s "${DISK}" mklabel gpt
parted -s "${DISK}" mkpart primary fat32 1MiB 513MiB
parted -s "${DISK}" set 1 boot on
parted -s "${DISK}" set 1 esp on
parted -s "${DISK}" mkpart primary 513MiB 100%

mkfs.vfat -n FS_BOOT -F32 "${DISK}p1"

cryptsetup luksFormat --type luks1 "${DISK}p2"
cryptsetup luksOpen "${DISK}p2" encroot

pvcreate /dev/mapper/encroot
vgcreate logicencroot /dev/mapper/encroot
lvcreate -L ${LVM_SWAP_SIZE} logicencroot -n SWAP
lvcreate -L ${LVM_OS_SIZE} logicencroot -n OS
lvcreate -l +100%FREE logicencroot -n DATA

mkswap -L FS_SWAP /dev/mapper/logicencroot-SWAP
mkfs.ext4 -L FS_OS /dev/mapper/logicencroot-OS
mkfs.ext4 -L FS_DATA /dev/mapper/logicencroot-DATA

swapon /dev/mapper/logicencroot-SWAP
mount /dev/mapper/logicencroot-OS /mnt
mkdir -p /mnt/home
mount /dev/mapper/logicencroot-DATA /mnt/home

mkdir -p /mnt/boot
mount "${DISK}p1"

pacstrap -i /mnt \
    ansible \
    base \
    base-devel \
    dhcpcd \
    dialog \
    efibootmgr \
    git \
    grub \
    intel-ucode \
    linux \
    linux-firmware \
    lvm2 \
    net-tools \
    vi \
    wireless_tools \
    wpa_supplicant \

genfstab -U -p /mnt >> /mnt/etc/fstab

lsblk --fs
cat /etc/fstab

arch-chroot /mnt /bin/bash
LANG=en_US.UTF-8
echo "${LANG} UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=${LANG}" > /etc/locale.conf
ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc --utc
echo "${MACHINE}" > /etc/hostname
systemctl enable dhcpcd.service
passwd

sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect keyboard modconf block sd-encrypt sd-lvm2 filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -p linux

bootctl install

PART_UUID=$(blkid -s UUID -o value "${DISK}p2")

cp -rf ./boot/* /etc/boot/
sed -i "s#PART_UUID#${PART_UUID}#g" /boot/loader/entries/arch.conf
