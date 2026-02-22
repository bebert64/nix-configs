{
  pkgs,
  lib,
  config,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  insomnia =
    {
      fetchurl,
      appimageTools,
    }:
    let
      pname = "insomnia-stockly";
      version = "11.0.0";
      src = fetchurl {
        url = "https://stockly-public-assets.s3.eu-west-1.amazonaws.com/Insomnia.Core-${version}-patchedv2.AppImage";
        hash = "sha256-bB1Qrm/Ii9KKwj01nnbVkjNIqZduPCstaTiWaGOGtJg=";
      };
    in
    appimageTools.wrapType2 {
      inherit pname version src;

      extraInstallCommands =
        let
          appimageContents = appimageTools.extract {
            inherit pname version src;
          };
        in
        ''
          install -Dm444 ${appimageContents}/insomnia.desktop -t $out/share/applications
          install -Dm444 ${appimageContents}/insomnia.png -t $out/share/pixmaps
          substituteInPlace $out/share/applications/insomnia.desktop \
              --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname}'
        '';
    };
in
{
  home.packages = [ (pkgs.callPackage insomnia { }) ];
  xsession.windowManager.i3.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+i" = "workspace $ws13; exec insomnia-stockly";
    };
    assigns = {
      "$ws13" = [ { class = "insomnia|Insomnia"; } ];
    };
  };
}
