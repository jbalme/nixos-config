{ self, nixpkgs, home-manager, ... }:
with nixpkgs.lib;
nixosSystem {
  system = "x86_64-linux";
  modules = with self.nixosModules; [
    {
      boot.zfs.extraPools = [ "tank" ];
      networking.hostName = "saturn";
      networking.hostId = "b988b583";
      networking.firewall.allowedTCPPorts = [ 80 443 6443 ];
      nix.maxJobs = 8;
      system.configurationRevision = mkIf (self ? rev) self.rev;
      system.stateVersion = "20.09";
    }
    hardware.cpu.intel
    hardware.disks.boot
    hardware.disks.zfs
    hardware.gpu.amd
    hardware.peripherals.cm-storm-devastator
    hardware.peripherals.ratbag
    services.kubernetes.k3s
    home-manager.nixosModules.home-manager
    configuration
  ];
}
