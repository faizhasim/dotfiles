{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Default to personal 1Password account when using `op` CLI
  # Avoids picking up company account in shared/dev contexts
  home.sessionVariables = {
    OP_ACCOUNT = "my";
  };
}
