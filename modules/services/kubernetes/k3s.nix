{ lib, ... }:
{
  services.k3s = {
    enable = true;
    extraFlags = "--disable traefik,local-storage";
  };
  
  # https://github.com/NixOS/nixpkgs/issues/103158
  systemd.services.k3s.after = [ "network-online.service" "firewall.service" ];
  systemd.services.k3s.serviceConfig.KillMode = lib.mkForce "control-group";

  # https://github.com/NixOS/nixpkgs/issues/98766
  boot.kernelModules = [ "br_netfilter" "ip_conntrack" "ip_vs" "ip_vs_rr" "ip_vs_wrr" "ip_vs_sh" "overlay" ];  
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i cni+ -j ACCEPT
  '';
}
