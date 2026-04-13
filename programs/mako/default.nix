_: {
  services.mako = {
    enable = true;
    settings = {
      font = "monospace 14";
      background-color = "#1a1b26";
      text-color = "#c0caf5";
      border-color = "#414868";
      border-radius = 6;
      border-size = 1;
      padding = "16,20";
      width = 600;
      height = 200;
      default-timeout = 8000;
      anchor = "top-center";
      margin = "10";
    };
    extraConfig = ''
      [urgency=low]
      default-timeout=5000

      [urgency=critical]
      background-color=#1a1b26
      text-color=#f7768e
      border-color=#f7768e
      default-timeout=0
    '';
  };
}
