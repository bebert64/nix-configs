# V0.1

echo "Hello and welcome my Don Config mega helper !!"

# Check is sudo is installed
if ! command -v sudo &> /dev/null
then
    echo "sudo could not be found. Install as root first"
    exit 1
fi

read -p 'flake-config name: ' FLAKE_CONFIG_NAME

# install yay
# pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay xorg-server xorg-xinit

# install nix if arch install not working
# for v0.2 if yay nix not working
curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install -o nix-install.sh
chmod +x ./nix-install.sh
./nix_install.sh --daemon

echo "You can reboot now"

# Setup nix
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# command to run first flake with --experimental-features
cd ~
cd ~/nix-configs/home-manager && home-manager switch --flake .#$FLAKE_CONFIG_NAME --extra-experimental-features nix-command --extra-experimental-features flakes

echo "All good, you can reboot and pray now"


## To add in v0.2

# # install additional packages1
# yay polkit alock
# # install rust
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# # Add line to fstab for nas
# # NAS
# sudo echo "nas.capucina.house:/volume1/NAS			/mnt/NAS	nfs		user,users,noexec,noauto	0 0" >> /etc/fstab

# # Needed for rofi to find apps
# # Add lines to /etc/profile
# sudo cat >> /etc/profile << EOL
# if [ -f $HOME/.nix-profile/etc/profile.d/nix.sh ];
# then
#      source $HOME/.nix-profile/etc/profile.d/nix.sh
# fi

# export XDG_DATA_DIRS=$HOME/.nix-profile/share:/usr/local/share:/usr/share:$HOME/.local/share:$XDG_DATA_DIRS
# EOL
