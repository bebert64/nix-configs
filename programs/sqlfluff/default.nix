# Terminal
{
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      sqlfluff
    ];
    file = {
      ".config/.sqlfluff".source = ./.sqlfluff;
    };
  };
}
