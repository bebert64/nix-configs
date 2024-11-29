{ config, lib, ... }:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  gmailAccount = address: {
    address = address;
    flavor = "gmail.com";
    realName = "Romain Cassan";
    thunderbird = {
      enable = true;
    };
  };
in
{
  accounts.email.accounts = {
    bebert64 = gmailAccount "bebert64@gmail.com" // {
      primary = true;
      aliases = [ "romain.cassan.64@gmail.com" ];
    };
    stockly = gmailAccount "romain@stockly.ai";
  };

  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      # Necessary for gmail oauth2 to work
      settings = {
        # For bebert64
        "mail.server.server_e834497f008a126ed365f02d8412dac1c4c265c127b9bccda5022be9506c5dba.authMethod" =
          10;
        "mail.smtpserver.smtp_e834497f008a126ed365f02d8412dac1c4c265c127b9bccda5022be9506c5dba.authMethod" =
          10;
        # For stockly
        "mail.server.server_cbaa1f5c537cd000837507ad54378a8babf63212057c78457d0a07bd8dfe4e17.authMethod" =
          10;
        "mail.smtpserver.smtp_cbaa1f5c537cd000837507ad54378a8babf63212057c78457d0a07bd8dfe4e17.authMethod" =
          10;
      };
    };
  };

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws5" = [ { class = "thunderbird"; } ];
    };
    keybindings = lib.mkOptionDefault { "${modifier}+Control+t" = "workspace $ws5; exec thunderbird"; };
  };
}
