{
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  programs.zsh = {
    enable = true;
    initContent = ''
      DISABLE_AUTO_TITLE="true"

      _get_project_name() {
        local dir="$PWD"

        if [[ "$dir" == "${homeDir}" ]]; then
          echo "Home"
          return
        fi

        if [[ "$dir" == "${homeDir}/Stockly"* ]]; then
          if [[ "$dir" == "${homeDir}/Stockly" ]]; then
            echo "Stockly - Home"
          else
            local rel="''${dir#${homeDir}/Stockly/}"
            local top="''${rel%%/*}"
            if [[ "$top" == "Main" ]]; then
              echo "Stockly - Main"
            elif [[ "$top" == Main_* ]]; then
              echo "Stockly - ''${top#Main_}"
            else
              echo "Stockly - $top"
            fi
          fi
          return
        fi

        if [[ "$dir" == "${homeDir}/code"* ]]; then
          if [[ "$dir" == "${homeDir}/code" ]]; then
            echo "Perso - Home"
          else
            local rel="''${dir#${homeDir}/code/}"
            local top="''${rel%%/*}"
            if [[ "$top" == "nix-configs" ]]; then
              echo "Nix - Home"
            elif [[ "$top" == nix-configs_* ]]; then
              echo "Nix - ''${top#nix-configs_}"
            elif [[ "$top" == "Main" ]]; then
              echo "Perso - Code"
            elif [[ "$top" == Main_* ]]; then
              echo "Perso - ''${top#Main_}"
            else
              echo "Perso - $top"
            fi
          fi
          return
        fi
      }

      _title_suffix() {
        local project host
        project="$(_get_project_name)"
        host="$(hostname)"
        if [[ -n "$project" ]]; then
          echo " ($host: $project)"
        else
          echo " ($host)"
        fi
      }

      _auto_title_precmd() {
        print -Pn "\e]2;%n@%m:%~$(_title_suffix)\a"
      }

      _auto_title_preexec() {
        local title="$1"
        [[ "$title" == claude* ]] && title="* Claude Code"
        print -Pn "\e]2;$title$(_title_suffix)\a"
      }

      precmd_functions+=(_auto_title_precmd)
      preexec_functions+=(_auto_title_preexec)
    '';
  };
}
