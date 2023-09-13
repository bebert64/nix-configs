loadkeys fr
timedatectl
mkfs.ext4 /dev/sda4
mount /dev/sd4 /mnt
mount /def/sda3 /mnt/boot
swapon /dev/sda2
reflector
pacstrap -K /mnt base linux linux-firmware vim git
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr" > /etc/vconsole.conf
echo "fixe-bureau" > /etc/hostname
passwd
useradd -m -G wheel romain
passwd romain
su romain
cd $HOME
git clone https://github.com/bebert64/nix-configs
echo "you can now reboot"
