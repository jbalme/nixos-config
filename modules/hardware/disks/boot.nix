{ pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices.crypt0.device = "/dev/disk/by-partlabel/LINUX";
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/EFIBOOT";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/mapper/vg0-root";
    fsType = "ext4";
  };

  swapDevices = [{ device = "/dev/mapper/vg0-swap"; }];
}
