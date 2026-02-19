{ pkgs, lib, ... }:

let
  jaJetfilterBaseUrl = "https://ipfs.io/ipfs/bafybeih65no5dklpqfe346wyeiak6wzemv5d7z2ya7nssdgwdz4xrmdu6i";
  jaNetfilter = pkgs.stdenv.mkDerivation {
    # https://jetbra.in/s
    name = "ja-netfilter";
    src = pkgs.fetchzip {
      url = "${jaJetfilterBaseUrl}/files/jetbra-8f6785eac5e6e7e8b20e6174dd28bb19d8da7550.zip";
      hash = "sha256-FvjwrmRE9xXkDIIkOyxVEFdycYa/t2Z0EgBueV+26BQ=";
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
  jetbrainsKeys = pkgs.callPackage (
    { pkgs, stdenvNoCC }:
    stdenvNoCC.mkDerivation {
      name = "jetbrains-keys";

      src = pkgs.fetchurl {
        url = jaJetfilterBaseUrl;
        hash = "sha256-/ojbOi/nXxnMEMbz9RDyVz01/a/20SW9GxG/Wvjzmic=";
      };
      dontUnpack = true;

      installPhase =
        let
          runtimeInputs = with pkgs; [
            jq
            xclip
            iconv
          ];
        in
        ''
          runHook preInstall

          mkdir -p $out/bin
          cat "$src" | grep "let jbKeys = " | sed -E 's/^[^{]*(\{.*\})+.*$/\1/' > "$out/jetbrains-keys.json"
          cat <<EOF >> "$out/bin/jetbrains-keys"
          #!/usr/bin/env bash
          set -euo pipefail
          export PATH="${lib.makeBinPath runtimeInputs}:\$PATH"
          PRODUCT_CODE="\''${1-}"
          if [ -z "\$PRODUCT_CODE" ]; then
            xdg-open "${jaJetfilterBaseUrl}"
          else
            ACTIVATION_OUTPUT_FILE="\''${2-}"
            if [ -n "\$ACTIVATION_OUTPUT_FILE" ]; then echo "Product code: \$PRODUCT_CODE"; fi
            ACTIVATION_CODE=\$(jq -r ".\$PRODUCT_CODE.[]" "$out/jetbrains-keys.json")
            if [ -z "\$ACTIVATION_OUTPUT_FILE" ]; then
              echo \$ACTIVATION_CODE
              xclip -selection clipboard <<< "\$ACTIVATION_CODE"
            else
              mkdir -p "\$(dirname "\$ACTIVATION_OUTPUT_FILE")"
              (printf "\xff\xff" && (printf "<certificate-key>\n\$ACTIVATION_CODE" | iconv --from-code UTF-8 --to-code UCS2)) > "\$ACTIVATION_OUTPUT_FILE"
            fi
          fi
          EOF
          chmod 555 "$out/bin/jetbrains-keys"
          chmod 444 "$out/jetbrains-keys.json"
          chmod 555 "$out"

          runHook postInstall
        '';
    }
  ) { };
  withJaNetfilter = builtins.mapAttrs (
    name: product:
    product.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        set -eo pipefail

        VM_OPTIONS_FILE_PATH=$(${pkgs.jq}/bin/jq -r '.launch[].vmOptionsFilePath' "$out/$pname/product-info.json")
        cat <<EOF >> $out/$pname/$VM_OPTIONS_FILE_PATH

        --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
        --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED

        -javaagent:${jaNetfilter}/ja-netfilter.jar=jetbrains
        EOF
      '';
    })
  ) pkgs.jetbrains;
  withAutoActivation = builtins.mapAttrs (
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
        APPDATA="\$HOME/.config/JetBrains/$(${pkgs.jq}/bin/jq -r '.dataDirectoryName' $PRODUCT_INFO_JSON)"
        KEY_FILE_PREFIX=$(${pkgs.jq}/bin/jq -r '.launch[].launcherPath' $PRODUCT_INFO_JSON)
        KEY_FILE_PREFIX=$(basename $KEY_FILE_PREFIX)
        KEY_FILE_PREFIX=''${KEY_FILE_PREFIX%.*}
        sed -i "2i${jetbrainsKeys}/bin/jetbrains-keys '$PRODUCT_CODE' \"$APPDATA/$KEY_FILE_PREFIX.key\"" "$out/$pname/$IDE_BIN_PATH"
      '';
    })
  ) withJaNetfilter;
in

withAutoActivation
// {
  noAutoActivation = withJaNetfilter;
  inherit jetbrainsKeys;
}
