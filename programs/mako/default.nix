{ ... }:
{
  services.mako = {
    enable = true;
    settings = {
      font = "monospace 10";
      background-color = "#1a1b26";
      text-color = "#c0caf5";
      border-color = "#414868";
      border-radius = 6;
      border-size = 1;
      padding = "10,12";
      default-timeout = 8000;
      anchor = "bottom-right";
      margin = "10";
    };
    extraConfig = ''
      [urgency=low]
      default-timeout=5000

      [urgency=critical]
      anchor=top-center
      background-color=#1a1b26
      text-color=#f7768e
      border-color=#f7768e
      default-timeout=0
    '';
  };
}
