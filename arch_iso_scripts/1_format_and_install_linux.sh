#!/usr/bin/env bash
set -euo pipefai

echo "Starting Arch Linux installation"
loadkeys fr
timedatectl

echo "Formating partitions"
mkfs.ext4 /dev/sda4
mkfs.fat -F 32 /dev/sda3

echo "Mounting partitions"
mount /dev/sda4 /mnt
mount /dev/sda3 /mnt/boot --mkdir
swapon /dev/sda2

echo "Install packages on new system"
reflector
pacstrap -K /mnt base linux linux-firmware vim git sudo grub efibootmgr networkmanager base-devel dconf

echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab
echo "nas.capucina.house:/volume1/NAS			/mnt/NAS	nfs		user,users,noexec,auto	0 0" >> /mnt/etc/fstab

echo "Copying scripts to new system"
cp -r /scripts /mnt

echo "Chrooting into new system"
arch-chroot /mnt bash -c 'echo "You should now run /scripts/2_create_user_and_switch.sh"'
