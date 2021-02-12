{
  description = "My personal NixOS configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-20.09";
    nur.url = "github:nix-community/NUR";
    neovim.url = "github:neovim/neovim?dir=contrib";
  };

  outputs = { self, flake-utils, nixpkgs, nixpkgs-unstable, home-manager, nur, neovim, ... }@inputs:
    with flake-utils // nixpkgs.lib // builtins; {
      # Pull in all modules from ./modules
      nixosModules = let
        dToA = dir:
          mapAttrs' (n: v:
            if v == "directory" then {
              name = n;
              value = dToA (dir + "/${n}");
            } else {
              name = (removeSuffix ".nix" n);
              value = import (dir + "/${n}");
            }) (readDir dir);
      in dToA ./modules // {
        common = {
          nixpkgs.overlays = [
            (this: super: rec {
              unfree = import "${nixpkgs}" {
                system = super.system;
                config.allowUnfree = true;
              };
              unstable = import "${nixpkgs-unstable}" {
                system = super.system;
                config.allowUnfree = true;
              };
              ofono = unstable.ofono;
              neovim-git = neovim.defaultPackage.${super.system};
            })
            nur.overlay
          ];
        };
      };

      # Pull in all systems from ./systems
      nixosConfigurations = let
        dToA = dir:
          mapAttrs' (n: v:
            if v == "directory" then {
              name = n;
              value = dToA (dir + "/${n}");
            } else {
              name = (removeSuffix ".nix" n);
              value = import (dir + "/${n}") inputs;
            }) (readDir dir);
      in dToA ./systems;
    };
}
