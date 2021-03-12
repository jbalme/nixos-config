#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash curl git jq nixUnstable

# PKG=ungoogled-chromium
# EVAL=$(curl -LX GET "https://hydra.nixos.org/job/nixos/release-20.09/nixpkgs.$PKG.x86_64-linux/latest" -H "accept: application/json" | jq .jobsetevals[0])
# REV=$(curl -LX GET "https://hydra.nixos.org/eval/$EVAL" -H "accept: application/json" | jq -r .jobsetevalinputs.nixpkgs.revision)
nix flake update --update-input nixpkgs
nix flake update --update-input home-manager
# nix flake update --override-input nixpkgs-chromium "github:NixOS/nixpkgs?rev=$REV"