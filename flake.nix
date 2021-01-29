{
  description = "My personal NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    # ungoogled-chromium frequently fails on hydra, let's pin it separately
    nixpkgs-chromium.url = "github:NixOS/nixpkgs/nixos-20.09";
    home-manager.url = "github:nix-community/home-manager/release-20.09";
  };

  outputs = { self, nixpkgs, nixpkgs-chromium, home-manager, ... }@inputs:
    with nixpkgs.lib // builtins; {

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
              ungoogled-chromium = nixpkgs-chromium.legacyPackages.${super.system}.ungoogled-chromium;
            })
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
