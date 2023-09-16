#!/usr/bin/env bash
set -euo pipefail

read -p 'Do you want to format the boot partition as well? (y/n) :' FORMAT_BOOT

loadkeys fr
timedatectl
mkfs.ext4 /dev/sda4
if [[ $FORMAT_BOOT == "y" ]]; then
    mkfs.fat -F 32 /dev/sda3
fi
mount /dev/sd4 /mnt
mount /def/sda3 /mnt/boot --mkdir
swapon /dev/sda2
reflector
pacstrap -K /mnt base linux linux-firmware vim git sudo grub efibootmgr networkmanager base-devel dconf
genfstab -U /mnt >> /mnt/etc/fstab
echo "nas.capucina.house:/volume1/NAS			/mnt/NAS	nfs		user,users,noexec,noauto	0 0" >> /etc/fstab
cp -r /scripts /mnt
cp -r /ssh /mnt

arch-chroot /mnt
