{ self, nixpkgs, home-manager, ... }:
with nixpkgs.lib;
nixosSystem {
  system = "x86_64-linux";
  modules = with self.nixosModules; [
    common
    ({ pkgs, ... }: {
      boot.zfs.extraPools = [ "tank" ];
      networking.hostName = "saturn";
      networking.hostId = "b988b583";
      networking.firewall.allowedTCPPorts = [ 80 443 6443 8080 ];
      nix.maxJobs = 8;
      system.configurationRevision = mkIf (self ? rev) self.rev;
      system.stateVersion = "20.09";
      services.xserver.displayManager.setupCommands = ''
        ${pkgs.xorg.xset}/bin/xset led 3
      '';
    })
    hardware.cpu.intel
    hardware.disks.boot
    hardware.gpu.amd
    services.kubernetes.k3s
    home-manager.nixosModules.home-manager
    configuration
  ];
}
