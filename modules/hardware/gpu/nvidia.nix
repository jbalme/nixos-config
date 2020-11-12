{
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.deviceSection = ''
    Option      "Coolbits" "31"
  '';
}
