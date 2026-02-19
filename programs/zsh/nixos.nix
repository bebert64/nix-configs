{ lib, ... }:
let
  common = import ./common.nix;
in
{
  programs.zsh = {
    enable = true;
    histSize = common.historySize;
    setOptions = [
      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
      "HIST_FCNTL_LOCK"
    ]
    ++ lib.optional common.extendedHistory "EXTENDED_HISTORY";
    ohMyZsh.enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      jc = "journalctl -xefu";
      jcb = "jc backup --user";
      jcc = "jc comfyui";
      jcgt = "jc guitar-tutorials --user";
      jcg = "jc guitar --user";
      jcm = "jc media --user";
      jcs = "jc shortcuts --user";
      jcwd = "jc wallpapers-download --user";
      ss = "systemctl status";
      ssc = "ss comfyui";
      ssg = "ss guitar --user";
      ssm = "ss media --user";
      ssq = "ss qbittorrent --user";
      sss = "ss stash --user";

      nix-shell = "nix-shell --run zsh";
    };

    interactiveShellInit = ''
      psg() {
        ps aux | grep $1 | grep -v psg | grep -v grep
      }
      run() {
        nix run "nixpkgs#$1" -- "''${@:2}"
      }

      wol-ssh() {
        ssh raspi5 "/home/romain/.local/bin/wol-by-db $2"
        while ssh raspi5 "! ping -c1 $3 &> /dev/null"; do
          echo "$1 is not responding"
          sleep 1
        done
        ssh $1 -t "zsh -i"
      }
      wb() {
        wol-ssh bureau D4:3D:7E:D8:C3:95 192.168.1.4
      }
      ws() {
        wol-ssh salon 74:56:3c:36:71:db 192.168.1.6
      }
    '';
  };
}
