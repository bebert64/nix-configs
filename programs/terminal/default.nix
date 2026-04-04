{ lib, ... }:
{
  wayland.windowManager.sway.config = {
    terminal = lib.mkForce "kitty";
  };
}
