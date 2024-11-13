{
  config.programs.btop = {
    enable = true;
    settings = {
      color_theme = "gruvbox_dark_v2";
      theme_background = false;
      proc_sorting = "memory";
      proc_tree = true;
      proc_aggregate = true;
      use_fstab = true;
    };
  };
}
