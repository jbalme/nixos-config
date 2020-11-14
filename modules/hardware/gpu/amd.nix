{ pkgs, lib, ... }:
with lib; {
  # Newer kernels tend to have better AMDGPU support.
  boot.kernelPackages = with pkgs; mkDefault linuxPackages_latest;

  hardware.opengl = rec {
    extraPackages = with pkgs; [ amdvlk ];
    extraPackages32 = extraPackages;
  };
}
