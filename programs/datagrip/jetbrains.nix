{
  pkgs,
  lib,
  ...
}:

let
  ja-jetfilter-base-url = "https://3.jetbra.in";
  ja-netfilter = pkgs.stdenv.mkDerivation {
    # https://jetbra.in/s
    name = "ja-netfilter";
    src = pkgs.fetchzip {
      url = "${ja-jetfilter-base-url}/files/jetbra-5a50fc03d68a014f893b7fc3aa465380d59f9095.zip";
      hash = "sha256-iCtLAmJ1uBU2VtU/EbgASI5Ws9pUJUpWxOB6xsZjgVs=";
    };
    installPhase = ''
      mkdir -p $out
      cp -ra --reflink=auto -- ./{ja-netfilter.jar,config-jetbrains,plugins-jetbrains} "$out"
    '';
  };
  product_code_overrides = {
    "pycharm" = "PC";
    "idea" = "II";
  };
  jetbrains-keys = pkgs.callPackage (
    { pkgs, stdenvNoCC }:
    stdenvNoCC.mkDerivation {
      name = "jetbrains-keys";

      src = pkgs.fetchurl {
        url = ja-jetfilter-base-url;
        hash = "sha256-cQc/LU13zDlv7f0ymBg7OBUJ7ISc+/TDrLpubQzAn1o=";
      };
      dontUnpack = true;

      env = {
        jetbrains_keys_bin_path = lib.makeBinPath (
          with pkgs;
          [
            jq
            xclip
            iconv
          ]
        );
        ja_netfilter_base_url = ja-jetfilter-base-url;
      };

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        cat "$src" | grep "let jbKeys = " | sed -E 's/^[^{]*(\{.*\})+.*$/\1/' > "$out/jetbrains-keys.json"
        substituteAll ${./jetbrains-keys.sh} "$out/bin/jetbrains-keys"
        chmod 555 "$out/bin/jetbrains-keys"
        chmod 444 "$out/jetbrains-keys.json"
        chmod 555 "$out"

        runHook postInstall
      '';
    }
  ) { };
  with-ja-netfilter = builtins.mapAttrs (
    name: product:
    product.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        set -eo pipefail

        VM_OPTIONS_FILE_PATH=$(${pkgs.jq}/bin/jq -r '.launch[].vmOptionsFilePath' "$out/$pname/product-info.json")
        cat <<EOF >> $out/$pname/$VM_OPTIONS_FILE_PATH

        --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
        --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED

        -javaagent:${ja-netfilter}/ja-netfilter.jar=jetbrains
        EOF
      '';
    })
  ) pkgs.jetbrains;
  with-auto-activation = builtins.mapAttrs (
    name: product:
    product.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        PRODUCT_INFO_JSON="$out/$pname/product-info.json"
        IDE_BIN_PATH=$(${pkgs.jq}/bin/jq -r '.launch[].launcherPath' "$PRODUCT_INFO_JSON")
        PRODUCT_CODE="${
          product_code_overrides.${name}
            or (product_code_overrides.${builtins.head (lib.splitString "-" name)}
            or ''$(${pkgs.jq}/bin/jq -r '.productCode' "$PRODUCT_INFO_JSON")''
            )
        }"
        APPDATA=$(${pkgs.jq}/bin/jq -r '.dataDirectoryName' $PRODUCT_INFO_JSON)
        APPDATA="\$HOME/.config/JetBrains/$APPDATA"
        APPDATA_DIR_WITHOUT_VERSION=$(echo "$APPDATA" | sed -E 's/20[0-9.]+$//')
        KEY_FILE_PREFIX=$(${pkgs.jq}/bin/jq -r '.launch[].launcherPath' $PRODUCT_INFO_JSON)
        KEY_FILE_PREFIX=$(basename $KEY_FILE_PREFIX)
        KEY_FILE_PREFIX=''${KEY_FILE_PREFIX%.*}
        sed -i "2i${jetbrains-keys}/bin/jetbrains-keys '$PRODUCT_CODE' \"$APPDATA/$KEY_FILE_PREFIX.key\" \"$APPDATA_DIR_WITHOUT_VERSION\" " "$out/$pname/$IDE_BIN_PATH"
      '';
    })
  ) with-ja-netfilter;
in

with-auto-activation
// {
  no-auto-activation = with-ja-netfilter;
  inherit jetbrains-keys;
}
