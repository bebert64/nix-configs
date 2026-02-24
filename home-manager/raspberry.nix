{
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ../programs/ranger
  ];

  config = {
    home = {
      packages = [
        (pkgs.writeScriptBin "wol-by-db" ''
          #!/usr/bin/env bash
          TARGETMAC="$1"

          if [ -z "$TARGETMAC" ]; then
            echo "Usage: $0 <MAC_ADDRESS>" >&2
            exit 1
          fi

          (
            printf 'ffffffffffff'
            for i in $(seq 1 16); do
              echo -n ''${TARGETMAC//:/}
            done
          ) | xxd -r -p | socat - UDP4-DATAGRAM:192.168.1.255:9,broadcast
        '')
      ];
    };
  };
}
