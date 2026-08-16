{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.mise = {
    enable = true;
    enableZshIntegration = false; # Disable auto-integration, we'll do it manually
    package = pkgs.mise;
    globalConfig = {
      tools = {
        bun = "latest";
        "github:can1357/oh-my-pi" = "latest"; # OMP coding agent (replacing Pi)
        go = "1.25.3";
        herdr = "latest";
        node = "lts";
        "pipx:specify-cli" = "latest"; # spec-kit CLI for Spec-Driven Development
        pnpm = "latest"; # aqua:pnpm/pnpm — decoupled from node/corepack (corepack dropped in Node 25+)
        python = [ "3.11" ];
        ruby = "latest";
        uv = "latest"; # Fast Python package manager
      };
      settings = {
        idiomatic_version_file_enable_tools = [
          "go"
          "java"
          "node"
          "pnpm" # reads packageManager/devEngines.packageManager from package.json
          "python"
          "ruby"
          "terraform"
          "terragrunt"
          "yarn"
        ];
        plugin_autoupdate_last_check_duration = "1 week";

        trusted_config_paths = [
          "~/dev"
        ];

        jobs = 4;
        raw = false;
        yes = false;

        env_file = ".env";
        experimental = true;

        npm = {
          package_manager = "pnpm"; # use pnpm as package manager for mise npm backend
        };
      };
    };
  };
}
