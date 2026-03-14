{ pkgs }:

with pkgs;
[
  # B
  buildkite-cli

  # L
  # localstack  # Temporarily disabled - broken in latest nixpkgs

  # S
  snyk
]
