{ ... }:
{
  services.mako = {
    enable = true;
    font = "monospace 10";
    backgroundColor = "#1a1b26";
    textColor = "#c0caf5";
    borderColor = "#414868";
    borderRadius = 6;
    borderSize = 1;
    padding = "10,12";
    defaultTimeout = 8000;
    anchor = "bottom-right";
    margin = "10";
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
