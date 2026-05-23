{
  config,
  pkgs,
  lib,
  ...
}:
{
  # QMD: Force CPU mode for node-llama-cpp (ggml-metal crashes on GPU teardown)
  # Upstream: https://github.com/ggml-org/llama.cpp/pull/17869
  # Once fixed in node-llama-cpp, remove this to re-enable Metal GPU acceleration
  home.sessionVariables = {
    QMD_FORCE_CPU = "1";
  };
}
