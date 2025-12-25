{ config, pkgs, lib, inputs, username, ... }: {
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.mise;
    globalConfig = {
      tools = {
        node = "lts";
        python = ["3.11"];
        bun = "latest";
        go = "1.25.3";
        # OpenCode - managed via mise for auto-updates, config via home-manager
        "github:sst/opencode" = "latest";
      };
      settings = {
        idiomatic_version_file_enable_tools = ["node" "java" "go" "python" "ruby" "terraform" "terragrunt" "yarn"];
        plugin_autoupdate_last_check_duration = "1 week";

        trusted_config_paths = [
          "~/dev"
        ];

        jobs = 4;
        raw = false;
        yes = false;

        env_file = ".env";
        experimental = true;
      };
    };
  };
}
