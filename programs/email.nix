{
  config,
  lib,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
in
{
  accounts.email.accounts = {
    name = "bebert64";
    address = "bebert64@gmail.com";
    aliases = [ "romain.cassan.64@gmail.com" ];
    flavor = "gmail.com";
    passwordCommand = "sops-read gmail/bebert64";
    primary = true;
    realName = "Romain Cassan";
    thunderbird = {
      enable = true;

    };
    # getmail = {
    #   enable = true;
    #   delete = true;
    # };
  };

  programs.thunderbird = {
    enable = true;
    profiles.default = {
      name = "default";
      isDefault = true;
    };
  };

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws5" = [ { class = "thunderbird"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+t" = "workspace $ws5; exec thunderbird -P Regular";
    };
  };
}
