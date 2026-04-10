{ ... }:
{
  imports = [ ./common.nix ];

  programs.zsh = {
    enable = true;
    initContent = ''
      claude-orthos() {
        local short_id="$1"
        local base="/home/romain/Stockly"

        if [[ -z "$short_id" ]]; then
          ssh -t orthos "printf '\033]2;* Claude Code (orthos: Main)\007' && cd '$base/Main' && claude; exec \$SHELL"
          return
        fi

        if [[ ! "$short_id" =~ ^[A-Za-z0-9]{5}$ ]]; then
          echo "Error: '$short_id' is not a valid short ID (must be exactly 5 alphanumeric characters)" >&2
          return 1
        fi

        ssh -t orthos "
          dir=\$(find '$base' -maxdepth 1 -type d -name 'Main_$short_id-*' | head -1)
          if [[ -z \"\$dir\" ]]; then
            echo \"Error: no directory found for short ID '$short_id'\" >&2
            exit 1
          fi
          printf '\033]2;* Claude Code (orthos: %s)\007' \"\$(basename \"\$dir\" | sed 's/^Main_//')\"
          cd \"\$dir\" && claude; exec \$SHELL
        "
      }
      alias co='claude-orthos'
    '';
  };
}
