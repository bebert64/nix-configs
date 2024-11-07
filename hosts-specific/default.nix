let
  hook_postswitch = bars: profile-name: ''
    echo "${bars}" > $HOME/.config/polybar/bars
    systemctl --user restart polybar
    systemctl --user restart wallpapers-manager
    echo "${profile-name}" > $HOME/.config/autorandr/current
  '';
in
{
  stockly-romainc = import ./stockly-romainc.nix hook_postswitch;
  raspi = import ./raspi.nix;
  fixe-bureau = import ./fixe-bureau.nix hook_postswitch;
}
