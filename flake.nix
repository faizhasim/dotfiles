{
  description = "A simple Nix flake for a basic project";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, darwin, nixpkgs, ... }:
    let
      user = "faizhasim";
      hostname = "M1196";
      system = "aarch64-darwin";

      unstable = import inputs.nixpkgs-unstable { inherit system; };
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
      darwinConfigurations.${hostname} = darwin.lib.darwinSystem {
        inherit system;
        # makes all inputs availble in imported files
        specialArgs = { inherit inputs; inherit unstable; };
        modules = [
          inputs.nix-index-database.darwinModules.nix-index
          ./darwin
          ({ pkgs, ... }: {

            # Fix the GID issue
            ids.gids.nixbld = 350;
            system = {
              stateVersion = 4;
              configurationRevision = self.rev or self.dirtyRev or null;
              primaryUser = user;
            };

            users.users.${user} = {
              home = "/Users/${user}";
              shell = pkgs.zsh;
            };

            networking = {
              computerName = hostname;
              hostName = hostname;
              localHostName = hostname;
            };

            nix = {
              settings = {
                allowed-users = [ user ];
                experimental-features = [ "nix-command" "flakes" ];
              };
            };

            environment.systemPackages = with pkgs; [
              cowsay
              lolcat
            ];
          })
        ];
      };
    };


}