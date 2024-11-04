let
  hook_postswitch = bars: ''
    echo "${bars}" > $HOME/.config/polybar/bars
    systemctl --user restart polybar
    systemctl --user restart wallpapers-manager
  '';
in
{
  stockly-romainc = import ./stockly-romainc.nix hook_postswitch;
  raspi = import ./raspi.nix;
  fixe-bureau = import ./fixe-bureau.nix hook_postswitch;
}
