#!/usr/bin/env bash
set -euo pipefail

# Set root password
passwd

# Finish system config
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr" > /etc/vconsole.conf
echo "fixe-bureau" > /etc/hostname
systemctl enable NetworkManager

# Install bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Grub
grub-mkconfig -o /boot/grub/grub.cfg

# Add user and give it sudo rights
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
useradd -m -G wheel romain
passwd romain

echo "you should now reboot"
