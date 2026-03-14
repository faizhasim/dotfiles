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
    direnv-1password = {
      url = "github:tmatilai/direnv-1password";
      flake = false;
    };
    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    worktrunk = {
      url = "github:max-sixty/worktrunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "darwin";
      inputs.home-manager.follows = "home-manager";
    };
    og-packs = {
      url = "github:PeonPing/og-packs/v1.1.0";
      flake = false;
    };
    peon-ping = {
      url = "github:PeonPing/peon-ping/v2.8.1";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      darwin,
      nixpkgs,
      home-manager,
      stylix,
      nord-dircolors,
      ...
    }:
    let
      # SSH key used for agenix secret decryption
      # Private key stored in 1Password (document: "agenix-decryption-key")
      # Extracted to ~/.ssh/agenix-key at system activation time
      # Both representations of the same key — SSH for identityPaths, age for publicKeys
      primarySshKey = {
        ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDmhrC+z9U+SYnvXhXRBWK47H34TMMr8cBdVpXuVHAAO";
        age = "age1qry8eztm55zgxek5npyu22v4j7akzdfapn249gmfhpg5gkwcasasqhdygq";
      };

      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      createDarwin =
        hostname: username: system:
        let
          overlays = import ./overlays {
            inherit inputs;
          };
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };
        in
        darwin.lib.darwinSystem {
          inherit system;
          # makes all inputs availble in imported files
          specialArgs = {
            inherit inputs;
            inherit hostname;
            inherit primarySshKey;
          };
          modules = [
            inputs.nix-index-database.darwinModules.nix-index
            stylix.darwinModules.stylix
            inputs.agenix.darwinModules.default
            ./darwin
            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = overlays;
                # Fix the GID issue
                ids.gids.nixbld = 350;

                # Add agenix CLI to system packages
                environment.systemPackages = [ inputs.agenix.packages.${system}.default ];

                system.stateVersion = 4;
                system.configurationRevision = self.rev or self.dirtyRev or null;
                system.primaryUser = username;

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
                    experimental-features = [
                      "nix-command"
                      "flakes"
                    ];
                  };

                  gc = {
                    automatic = true;
                    interval = {
                      Weekday = 0;
                      Hour = 2;
                      Minute = 0;
                    };
                    options = "--delete-older-than 30d";
                  };

                  extraOptions = ''
                    experimental-features = nix-command flakes
                  '';
                };

              }
            )

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                extraSpecialArgs = {
                  inherit inputs;
                  pkgs-zsh-fzf-tab = import inputs.nixpkgs-zsh-fzf-tab { inherit system; };
                };
                users.${username} =
                  {
                    pkgs,
                    config,
                    lib,
                    ...
                  }:
                  import ./home-manager {
                    inherit
                      config
                      pkgs
                      lib
                      inputs
                      hostname
                      username
                      nord-dircolors
                      ;
                  };

              };
            }
          ];
        };

    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages."${system}".nixfmt);
      darwinConfigurations = {
        M3419 = createDarwin "M3419" "faizhasim" "aarch64-darwin";
        macmini01 = createDarwin "macmini01" "faizhasim" "aarch64-darwin";
      };
    };

}
