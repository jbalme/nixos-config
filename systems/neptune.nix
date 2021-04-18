{ self, nixpkgs, home-manager, ... }:
with nixpkgs.lib;
nixosSystem {
  system = "x86_64-linux";
  modules = with self.nixosModules; [
    common
    {
      system.configurationRevision = mkIf (self ? rev) self.rev;
      networking.hostName = "neptune";
      networking.hostId = "b78f0031";
      system.stateVersion = "20.09";
      nix.maxJobs = 4;
    }
    hardware.cpu.intel
    hardware.disks.boot
    home-manager.nixosModules.home-manager
    configuration
  ];
}
