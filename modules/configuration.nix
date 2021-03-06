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

    nixpkgs = {
      config = { allowUnfree = true; };
      overlays = [
        (this: super: rec {
          steam = super.steam.override {
            extraLibraries = (pkgs: with pkgs; [
              #json-glib
            ]);
          };
        })
      ];
    };

    boot = {
      kernel = { sysctl = { "kernel.sysrq" = 1; }; };
      supportedFilesystems = [ "exfat" "ntfs" "zfs" ];
    };

    environment = {
      pathsToLink = [ "/share/zsh" ];

      systemPackages = with pkgs;
        with gnome3;
        with gst_all_1; [
          nautilus
          evince
          gnome-calculator
          gnome-logs
          file-roller
          eog
          evolution
          unzip
          git
          gst-plugins-base
          gst-plugins-ugly
          gst-plugins-good
          gst-plugins-bad
          gst-libav
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
      printers = {
        ensurePrinters = [{
          name = "OfficeJet_6600";
          model = "HP/hp-officejet_6600.ppd.gz";
          deviceUri = "hp:/net/Officejet_6600?hostname=HPD4C9EF79CBE0.local";
        }];
        ensureDefaultPrinter = "OfficeJet_6600";
      };
      pulseaudio = { enable = false; };
      sane = {
        enable = true;
        extraBackends = with pkgs; [ sane-airscan hplip ];
        netConf = "HPD4C9EF79CBE0.local";
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

      gnome = {
        at-spi2-core = { enable = mkForce false; };
        gnome-initial-setup = { enable = false; };
        tracker = { enable = false; };
        tracker-miners = { enable = false; };
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
        config = {
          pipewire = {
            default = {
              clock = {
                quantum = 32;
                min-quantum = 32;
                max-quantum = 768;
              };
            };
          };
        };
        media-session = {
          config = {
            alsa-monitor = {
              api = {
                alsa = {
                  use-ucm = true;
                  headroom = 1024;
                };
              };
            };
          };
        };
      };

      printing = {
        enable = true;
        drivers = with pkgs; [ gutenprint hplip ];
      };

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
        desktopManager = {
          gnome = {
            enable = true;
            flashback = {
              enableMetacity = true;
              #customSessions = [{
              #  wmName = "dwm";
              #  wmLabel = "dwm";
              #  wmCommand = "${pkgs.dwm}/bin/dwm";
              #}];
            };
          };
        };

        xkbOptions = "caps:none";
      };

      zerotierone = { enable = true; };
    };

    programs = {
      dconf = { enable = true; };
      steam = {
        enable = true;
        remotePlay = { openFirewall = true; };
      };
      zsh = {
        enable = true;
        enableBashCompletion = true;
        autosuggestions = { enable = true; };
        ohMyZsh = {
          enable = true;
          theme = "awesomepanda";
        };
        syntaxHighlighting = { enable = true; };
        shellInit = ''
          eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
        '';
      };
    };

    sound = { enable = true; };

    console.keyMap = locale.keyMap;
    i18n.defaultLocale = locale.locale;
    services.xserver.layout = locale.keyMap;
    time.timeZone = locale.timeZone;

    networking = {
      firewall = {
        enable = true;
      };
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

    security = {
      pam = {
        services =
          lib.genAttrs [ "lightdm" "gdm" ] (a: { enableGnomeKeyring = true; });
      };
    };

    virtualisation = {
      docker.enable = true;

      libvirtd = {
        enable = true;
        qemuRunAsRoot = false;
      };
    };

    users.users.user = {
      isNormalUser = true;
      extraGroups =
        [ "wheel" "networkmanager" "docker" "libvirtd" "scanner" "lp" ];
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
