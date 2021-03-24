{ pkgs, lib, config, ... }:
with lib;
let
  locale = {
    keyMap = "us";
    locale = "en_CA.UTF-8";
    timeZone = "America/Toronto";
  };
in {
  config = {
    nix = {
      package = pkgs.nixFlakes;
      extraOptions = "experimental-features = nix-command flakes";
    };

    nixpkgs = { config.allowUnfree = true; };

    boot = {
      kernel = { sysctl = { "kernel.sysrq" = 1; }; };
      supportedFilesystems = [ "exfat" "ntfs" "zfs" ];
    };

    environment = {
      pathsToLink = [ "/share/zsh" ];

      systemPackages = with pkgs;
        with gnome3; [
          nautilus
          evince
          gnome-calculator
          gnome-logs
          file-roller
          eog
          evolution
          unzip
          git
        ];
    };

    hardware = {
      bluetooth = { enable = true; };
      opengl = rec {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;

        extraPackages = with pkgs; [
          vaapiVdpau
          vaapiIntel
          libvdpau-va-gl
          intel-media-driver
        ];
        extraPackages32 = extraPackages;
      };
    };

    services = {
      avahi = {
        enable = true;
        ipv4 = true;
        ipv6 = true;
        nssmdns = true;

        publish = {
          enable = true;
          userServices = true;
          domain = true;
        };
      };

      blueman = { enable = true; };

      dbus = { packages = with pkgs; [ gcr ]; };

      gnome3 = {
        evolution-data-server = { enable = true; };
        gnome-online-accounts = { enable = true; };
        gnome-keyring = { enable = true; };
        sushi = { enable = true; };
      };

      gvfs = { enable = true; };

      openssh = {
        enable = true;
        permitRootLogin = "no";
        forwardX11 = true;
      };

      pipewire = {
        enable = true;
        pulse = { enable = true; };
        jack = { enable = false; };
        alsa = {
          enable = true;
          support32Bit = true;
        };
      };

      printing = { enable = true; };

      ratbagd = { enable = true; };

      upower = { enable = true; };

      xserver = {
        enable = true;
        libinput = {
          enable = true;
          mouse.middleEmulation = false;
        };
        displayManager = {
          session = [{
            name = "xsession";
            manage = "desktop";
            start = ''
              ${pkgs.runtimeShell} $HOME/.xsession &
              waitPID=$!
            '';
          }];
          defaultSession = "xsession";
          autoLogin = {
            enable = true;
            user = "user";
          };
        };
      };

      zerotierone = { enable = true; };
    };

    programs = { dconf = { enable = true; }; };

    sound = { enable = true; };

    console.keyMap = locale.keyMap;
    i18n.defaultLocale = locale.locale;
    services.xserver.layout = locale.keyMap;
    time.timeZone = locale.timeZone;

    networking = {
      firewall = { enable = true; };
      networkmanager.enable = true;
      useDHCP = false; # legacy flag
    };

    fonts.fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      corefonts
      vistafonts
      winePackages.fonts
    ];

    virtualisation = {
      docker.enable = true;

      libvirtd = {
        enable = true;
        qemuRunAsRoot = false;
      };
    };

    users.users.user = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" ];
      shell = pkgs.zsh;
    };

    home-manager = {
      users.user = ./home.nix;
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    qt5 = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
  };
}
