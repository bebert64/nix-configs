{ pkgs, ... }:

let
  ja-netfilter = pkgs.stdenv.mkDerivation {
    # https://jetbra.in/s
    name = "ja-netfilter";
    src = pkgs.fetchzip {
      url = "https://ipfs.io/ipfs/bafybeiatyghkzrrtodzt3stm652rkrjxndg4hq2ublfdmifk7plg5k5brq/files/jetbra-1126574a2f82debceb72e7f948eb7d4f616ffddf.zip";
      hash = "sha256-4YyUOHYeUoB5PGVpLQe7JeBvagQ6pgvo+j/ZJmVQGgY=";
    };
    installPhase = ''
      mkdir -p $out
      cp -ra --reflink=auto -- ./{ja-netfilter.jar,config-jetbrains,plugins-jetbrains} "$out"
    '';
  };
in

builtins.mapAttrs (
  name: product:
  product.overrideAttrs (oldAttrs: rec {
    postFixup =
      (oldAttrs.postFixup or "")
      + ''
        cat <<EOF >> $out/$pname/bin/*64.vmoptions

        --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
        --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED

        -javaagent:${ja-netfilter}/ja-netfilter.jar=jetbrains
        EOF
      '';
  })
) pkgs.jetbrains
