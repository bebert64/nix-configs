#!/usr/bin/env bash
set -euo pipefail

read -p 'Do you want to re-install the bootlader? (y/n) :' INSTALL_BOOTLOADER

passwd
# uncomment wheel line
visudo
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr" > /etc/vconsole.conf
echo "fixe-bureau" > /etc/hostname
systemctl enable NetworkManager
if [[ $FORMAT_BOOT == "y" ]]; then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux
    grub-mkconfig -o /boot/grub/grub.cfg
fi
useradd -m -G wheel romain
passwd romain

echo "you should now reboot"
