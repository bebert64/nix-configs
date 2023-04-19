{ fetchurl }:

let
  version = "1.0";
in fetchurl {
  name = "neuropol.otf";

  url = "https://github.com/bebert64/nixos-configs/blob/main/fonts/neuropol.otf";

  postFetch = ''
    mkdir -p $out/share/fonts/opentype
    unzip -j $downloadedFile \*.otf -d $out/share/fonts/opentype
  '';

  sha256 = "";

  meta =  {
    homepage = "https://rsms.me/inter/";
    description = "A typeface specially designed for user interfaces";
  };
}
