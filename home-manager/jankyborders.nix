{ config, pkgs, lib, inputs, ... }: {
  services.jankyborders = {
    enable = true;
    settings = {
      style = "round";
      width = 6.0;
      hidpi = "on";
      active_color = "0xFFB48EAD";
      # active_color = ''gradient(top_left=0xFFB48EAD,bottom_left=0xFFD08770)'';
      # inactive_color = "0xFF3B4252";
      # inactive_color = "0x7F3B4252";
    };
  };
}
