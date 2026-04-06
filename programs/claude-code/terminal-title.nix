{
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  inherit (config.byDb.paths) nixConfigs;
  nixConfigsBase = builtins.baseNameOf nixConfigs;
  nixConfigsParent = builtins.dirOf nixConfigs;
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

        if [[ "$dir" == "${nixConfigs}" || "$dir" == "${nixConfigs}/"* ]]; then
          local branch
          branch="$(git branch --show-current 2>/dev/null)"
          [[ -n "$branch" ]] && echo "$branch" || echo "Home"
          return
        fi

        if [[ "$dir" == "${nixConfigsParent}/${nixConfigsBase}_"* ]]; then
          local rel="''${dir#${nixConfigsParent}/${nixConfigsBase}_}"
          echo "''${rel%%/*}"
          return
        fi

        if [[ "$dir" == "${homeDir}/Stockly"* ]]; then
          if [[ "$dir" == "${homeDir}/Stockly" ]]; then
            echo "Home"
          else
            local rel="''${dir#${homeDir}/Stockly/}"
            local top="''${rel%%/*}"
            if [[ "$top" == "Main" ]]; then
              echo "Main"
            elif [[ "$top" == Main_* ]]; then
              echo "''${top#Main_}"
            else
              echo "$top"
            fi
          fi
          return
        fi

        if [[ "$dir" == "${homeDir}/code"* ]]; then
          if [[ "$dir" == "${homeDir}/code" ]]; then
            echo "Home"
          else
            local rel="''${dir#${homeDir}/code/}"
            local top="''${rel%%/*}"
            if [[ "$top" == "nix-configs" ]]; then
              echo "Home"
            elif [[ "$top" == nix-configs_* ]]; then
              echo "''${top#nix-configs_}"
            elif [[ "$top" == "Main" ]]; then
              echo "Code"
            elif [[ "$top" == Main_* ]]; then
              echo "''${top#Main_}"
            else
              echo "$top"
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
        if [[ "$title" == claude-orthos* ]]; then
          local args="''${title#claude-orthos}"
          args="''${args# }"
          if [[ -n "$args" ]]; then
            print -Pn "\e]2;Claude (orthos: $args)\a"
          else
            print -Pn "\e]2;Claude (orthos: Main)\a"
          fi
          return
        fi
        [[ "$title" == claude* ]] && title="Claude"
        print -Pn "\e]2;$title$(_title_suffix)\a"
      }

      precmd_functions+=(_auto_title_precmd)
      preexec_functions+=(_auto_title_preexec)
    '';
  };
}
