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
      networking.firewall.allowedTCPPorts = [ 80 443 6443 8080 27036 27037 ];
      networking.firewall.allowedUDPPorts = [ 27031 27036 ];
      nix.maxJobs = 8;
      system.configurationRevision = mkIf (self ? rev) self.rev;
      system.stateVersion = "20.09";
      services.xserver.displayManager.setupCommands = with pkgs.xorg; ''
        ${xrandr}/bin/xrandr --output HDMI-A-0 --mode 2560x1440 -r 75 --primary --output DisplayPort-2 --mode 1920x1080 -r 60 --left-of HDMI-A-0
        ${xset}/bin/xset led 3
        ${setxkbmap}/bin/setxkbmap -option caps:none
      '';
      services.jenkins = {
        enable = true;
        extraJavaOptions = [ "-Xms80m" "-Xmx256m" ];
        packages = with pkgs; [ stdenv git jdk nodejs nodePackages.npm newman ];
        port = 6969;
      };
    })
    hardware.cpu.intel
    hardware.disks.boot
    hardware.gpu.amd
    services.kubernetes.k3s
    home-manager.nixosModules.home-manager
    configuration
  ];
}
