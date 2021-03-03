{ pkgs, ... }: {
  boot = {
    loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
      memtest86.enable = true;
    };

    initrd = {
      luks.devices.crypt0 = {
        device = "/dev/disk/by-partlabel/LINUX";
        allowDiscards = true;
      };
      availableKernelModules =
        [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "nvme" ];
      kernelModules = [ "dm-snapshot" ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partlabel/EFIBOOT";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/mapper/vg0-root";
      fsType = "ext4";
    };
  };

  swapDevices = [{ device = "/dev/mapper/vg0-swap"; }];
}
