# loadkeys fr
# timedatectl
# mkfs.ext4 /dev/sda4
# mount /dev/sd4 /mnt
# mount /def/sda3 /mnt/boot --mkdir
# swapon /dev/sda2
# reflector
# pacstrap -K /mnt base linux linux-firmware vim git sudo
# genfstab -U /mnt >> /mnt/etc/fstab
# arch-chroot /mnt
# passwd
# useradd -m -G wheel romain
# passwd romain
# su romain
# cd


sudo ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
sudo hwclock --systohc
sudo sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sudo sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
sudo echo "LANG=en_US.UTF-8" > /etc/locale.conf
sudo echo "KEYMAP=fr" > /etc/vconsole.conf
sudo echo "fixe-bureau" > /etc/hostname
# git clone https://github.com/bebert64/nix-configs
echo "you can now reboot"
