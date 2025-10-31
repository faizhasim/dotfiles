{
  description = "A simple Nix flake for a basic project";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nord-dircolors = {
      url = "github:nordtheme/dircolors";
      flake = false;
    };
    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, darwin, nixpkgs, home-manager, stylix, nord-dircolors, ... }:
    let

      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      createDarwin =
        hostname: username: system:
        let
          overlays = import ./overlays;
          pkgs = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
          };
        in
          darwin.lib.darwinSystem {
            inherit system;
            # makes all inputs availble in imported files
            specialArgs = { inherit inputs; inherit hostname; };
            modules = [
              inputs.nix-index-database.darwinModules.nix-index
              stylix.darwinModules.stylix
              ./darwin
              ({ pkgs, ... }: {
                nixpkgs.overlays = overlays;
                # Fix the GID issue
                ids.gids.nixbld = 350;
                system = {
                  stateVersion = 4;
                  configurationRevision = self.rev or self.dirtyRev or null;
                  primaryUser = username;
                };

                users.users.${username} = {
                  home = "/Users/${username}";
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
                    allowed-users = [ username ];
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

              })

              home-manager.darwinModules.home-manager {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "hm-backup";
                  extraSpecialArgs = {
                    inherit inputs;
                    pkgs-zsh-fzf-tab =
                      import inputs.nixpkgs-zsh-fzf-tab { inherit system; };
                  };
                  users.${username} = { pkgs, config, lib, ... }:
                    import ./home-manager { inherit config pkgs lib inputs hostname username nord-dircolors; };

                };
              }
            ];
          };

    in {
      formatter = forAllSystems (system: nixpkgs.legacyPackages."${system}".nixfmt);
      darwinConfigurations = {
        M3419 = createDarwin "M3419" "faizhasim" "aarch64-darwin";
        macmini01 = createDarwin "macmini01" "faizhasim" "aarch64-darwin";
        mbp01 = createDarwin "mbp01" "faizhasim" "x86_64-darwin";
      };
    };


}
