# # loadkeys fr
# # timedatectl
# # mkfs.ext4 /dev/sda4
# # mkfs.fat -F 32 /dev/sda3
# # mount /dev/sd4 /mnt
# # mount /def/sda3 /mnt/boot --mkdir
# # swapon /dev/sda2
# # reflector
# # pacstrap -K /mnt base linux linux-firmware vim git sudo grub efibootmgr networkmanager base-devel dconf
# # genfstab -U /mnt >> /mnt/etc/fstab
# # arch-chroot /mnt
# # passwd
# # # uncomment wheel line
# # visudo
# # useradd -m -G wheel romain
# # passwd romain
# # su romain
# # cd
# # git clone https://github.com/bebert64/nix-configs
# # cd nix-configs
# # sudo ./install_user_arch.sh


# systemctl enable NetworkManager
# ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
# hwclock --systohc
# sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
# sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /etc/locale.gen
# locale-gen
# echo "LANG=en_US.UTF-8" > /etc/locale.conf
# echo "KEYMAP=fr" > /etc/vconsole.conf
# echo "fixe-bureau" > /etc/hostname
# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux
# grub-mkconfig -o /boot/grub/grub.cfg

# echo "you can now reboot"
