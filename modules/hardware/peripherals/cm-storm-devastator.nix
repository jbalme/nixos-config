{ pkgs, ... }: {
  # The CM Storm Devastator keyboard uses the NumLock LED to toggle lighting
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xset}/bin/xset led 3
  '';
}
