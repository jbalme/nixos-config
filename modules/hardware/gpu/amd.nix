{ pkgs, lib, ... }:
with lib; {
  # Newer kernels tend to have better AMDGPU support.
  boot.kernelPackages = with pkgs; mkDefault linuxPackages_zen;

  # Enable early KMS.
  boot.initrd.kernelModules = [ "amdgpu" ];
}
