{
  services.k3s = {
    enable = true;
  };
  
  # https://github.com/NixOS/nixpkgs/issues/103158
  systemd.services.k3s.after = [ "network-online.service" "firewall.service" ];

  # https://github.com/NixOS/nixpkgs/issues/98766
  boot.kernelModules = [ "br_netfilter" "ip_conntrack" "ip_vs" "ip_vs_rr" "ip_vs_wrr" "ip_vs_sh" "overlay" ];  
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 10.42.0.0/16 -j ACCEPT
    iptables -A INPUT -d 10.42.0.0/16 -j ACCEPT
  '';
}
