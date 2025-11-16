{
  ...
}:
{
  # use homebrew until nix compile using SDK 26 https://github.com/NixOS/nixpkgs/issues/343210#issuecomment-3313995590
  # services.jankyborders = {
  #   enable = true;
  #   settings = {
  #     style = "round";
  #     width = 6.0;
  #     hidpi = "on";
  #     active_color = "0xFFB48EAD";
  #     # active_color = ''gradient(top_left=0xFFB48EAD,bottom_left=0xFFD08770)'';
  #     # inactive_color = "0xFF3B4252";
  #     # inactive_color = "0x7F3B4252";
  #   };
  # };

  xdg.configFile."borders/bordersrc" = {
    text = ''
      options=(
        style=round
        width=7.500000
        hidpi=on
        active_color=0xFFB48EAD
      )

      borders "''${options[@]}"
    '';
    executable = true;
  };

}
