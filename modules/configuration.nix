{ pkgs, lib, config, ... }:
with lib; {
  config = {
    # Enable Nix Unstable for flakes support.
    nix = {
      package = pkgs.nixUnstable;
      extraOptions = "experimental-features = nix-command flakes";
    };

    # Allow Unfree packages (needed for ZeroTier)
    nixpkgs.config.allowUnfree = true;

    # Locale settings
    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    services.xserver.layout = "us";
    time.timeZone = "America/Toronto";

    # Enable the magic SysRq key / 3-finger salute.
    boot.kernel.sysctl."kernel.sysrq" = 1;

    # Audio support
    sound.enable = true;
    hardware.pulseaudio = {
      enable = true;
      support32Bit = true;
      extraConfig = ''
        	    load-module module-echo-cancel use_master_format=1 aec_method=webrtc aec_args="analog_gain_control=0\ digital_gain_control=1\ noise_suppression=1\ voice_detection=1" source_name=ec_source sink_name=ec_sink
                set-default-sink ec_sink
                set-default-source ec_source
            '';
    };

    # Graphics support
    hardware.opengl = rec {
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

    # Networking
    networking = {
      firewall = { enable = true; };
      networkmanager.enable = true;
      useDHCP = false; # legacy flag
    };

    # Network services
    services.avahi = {
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

    services.openssh = {
      enable = true;
      permitRootLogin = "no";
      forwardX11 = true;
    };

    services.zerotierone.enable = true;

    # Print services
    services.printing.enable = true;

    # Display server
    services.xserver = {
      enable = true;
      libinput = {
        enable = true;
        middleEmulation = false;
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

    # Virtual Filesystem service
    services.gvfs.enable = true;

    # Fix for pinentry-gnome3
    services.dbus.packages = with pkgs; [ gcr ];

    # Power Management
    services.upower.enable = true;

    # Virtualization
    virtualisation = {
      docker.enable = true;

      libvirtd = {
        enable = true;
        qemuRunAsRoot = false;
      };
    };

    # ZSH autocompletion for system packages
    environment.pathsToLink = [ "/share/zsh" ];

    # Users
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
  };
}
