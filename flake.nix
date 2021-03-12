{
  description = "My personal NixOS configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    nur.url = "github:nix-community/NUR";
    neovim.url = "github:neovim/neovim?dir=contrib";
    dwm-status.url = "github:Gerschtli/dwm-status/master";
    dwm-status.flake = false;
  };

  outputs = { self, flake-utils, nixpkgs, nixpkgs-unstable, home-manager, nur, neovim, dwm-status, ... }@inputs:
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
            (this: super: {
              unfree = import "${nixpkgs}" {
                system = super.system;
                config.allowUnfree = true;
              };
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
