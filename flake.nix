{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      nrnSSHKey = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFU4FqKFDpHNUf8hYVckLE9Fb5K3kZK2ZtaUmazKFwWQ nrn@bl3ck'';
      rootSSHKey = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/oxB++zbxD8qLSw7Wgki2TPRI+YvrvPJOpXR9ks/ki root@bl3ck'';
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        inherit system;
        pkgs = pkgsForSystem system;
      });
      devTools = { system, pkgs }: [
        pkgs.minio-client
      ];
    in
    {
      devShells = forAllSystems ({ system, pkgs }: {
        default = pkgs.mkShell {
          buildInputs = (devTools { inherit system pkgs; });
        };
      });
      nixosConfigurations = {
        hetzner-dedicated-x86_64 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs nrnSSHKey rootSSHKey;
            system = "x86_64-linux";
          };
          modules = [
            ./systems/hetzner/dedicated/config.nix
            { nixpkgs.pkgs = pkgsForSystem "x86_64-linux"; }
          ];
        };
        builder-x86_64 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit nrnSSHKey rootSSHKey;
          };
          modules = [
            ./systems/utm/builder/config.nix
          ];
        };
        builder-aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit nrnSSHKey rootSSHKey;
          };
          modules = [
            ./systems/utm/builder/config.nix
          ];
        };
      };
    };
}
