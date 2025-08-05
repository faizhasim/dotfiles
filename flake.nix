{
  description = "A simple Nix flake for a basic project";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ self, darwin, nixpkgs, home-manager, mac-app-util, ... }:
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
          mac-app-util.darwinModules.default
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

            nixpkgs.config = {
              allowUnfree = true;
              # allowBroken = true;
              allowInsecure = false;
              # allowUnsupportedSystem = true;
            };

            nix = {
              settings = {
                allowed-users = [ user ];
                experimental-features = [ "nix-command" "flakes" ];
              };

              gc = {
                automatic = true;
                interval = { Weekday = 0; Hour = 2; Minute = 0; };
                options = "--delete-older-than 30d";
              };

              extraOptions = ''
                experimental-features = nix-command flakes
              '';
            };

            environment.systemPackages = with pkgs; [
              cowsay
              lolcat
            ];
          })

          home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs;
                inherit unstable;
                pkgs-zsh-fzf-tab =
                  import inputs.nixpkgs-zsh-fzf-tab { inherit system; };
              };
              sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
              users.${user} = { pkgs, config, lib, ... }:
                import ./home-manager { inherit config pkgs lib inputs; };

            };
          }
        ];
      };
    };


}