{ self, nixpkgs, home-manager, ... }:
with nixpkgs.lib;
nixosSystem {
  system = "x86_64-linux";
  modules = with self.nixosModules; [
    {
      system.configurationRevision = mkIf (self ? rev) self.rev;
      networking.hostName = "saturn";
      networking.hostId = "b988b583";
      system.stateVersion = "20.09";
      nix.maxJobs = 8;
      boot.zfs.extraPools = ["tank"];
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
