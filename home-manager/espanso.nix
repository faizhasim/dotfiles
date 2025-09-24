{ config, pkgs, lib, inputs, ... }: {
  services.espanso = {
    enable = true;
    matches = {
      base = {
        matches = [
          {
            trigger = ";td";
            replace = "{{isodate}}";
          }
          {
            trigger = ";ts";
            replace = "{{isodate}} {{hourminute}}";
          }
          {
            trigger = ";;;";
            replace = "{{clipb}}";
          }
        ];
      };
      global_vars = {
        global_vars = [
          {
            name = "isodate";
            type = "date";
            params = {format = "%Y-%m-%d";};
          }
          {
            name = "hourminute";
            type = "date";
            params = {format = "%R";};
          }
          {
            name = "clipb";
            type = "clipboard";
          }
        ];
      };
    };
  };
}
