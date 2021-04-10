{
  description = "My personal NixOS configuration";

  inputs = {
    flake-utils = { url = "github:numtide/flake-utils"; };
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    nixpkgs-unstable = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    home-manager = { url = "github:nix-community/home-manager/master"; };
    nur = { url = "github:nix-community/NUR"; };
    dwm = {
      url = "github:jbalme/dwm/main";
      flake = false;
    };
    userjs = {
      url = "github:jbalme/user.js/relaxed";
      flake = false;
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, flake-utils, nixpkgs, nixpkgs-unstable, home-manager, nur
    , ... }@inputs:
    with flake-utils // nixpkgs.lib // builtins; rec {
      inherit (nixpkgs) legacyPackages;

      overlay = (this: super: {
        inputs = inputs;
        outputs = self;
      });

      overlays = [ overlay nur.overlay ];

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
          nixpkgs.overlays = overlays;
          nix.registry.nixpkgs.flake = nixpkgs;
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
