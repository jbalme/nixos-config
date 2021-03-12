{ pkgs, lib, config, ... }:
with lib; {
  # for flake support
  home.stateVersion = "20.09";

  home.packages = with pkgs // pkgs.mate; [
    dmenu

    # communications
    zoom-us
    discord
    element-desktop

    # vidya
    steam
    steam-run

    # virtualization
    virt-manager

    # volume control
    pavucontrol

    # services
    mate-notification-daemon
    mate-polkit

    # apps
    #engrampa
    #caja-with-extensions
    #atril
    #eom
    #mate-calc

    # media tools
    youtube-dl
    imagemagick
    ffmpeg
    maim

    unzip

    # system
    htop
    ncdu

    # text tools
    pandoc
    tectonic

    # dotnet
    dotnet-sdk_5
  ];

  # git
  programs.git.enable = true;

  # gpg
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryFlavor = "gnome3";
  };

  # password manager
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };

  programs.browserpass.enable = true;

  # browser
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium.override { enableVaapi = true; };
  };

  programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
      browserpass
    ];
    profiles.default = {
      extraConfig = let
        userjs = pkgs.fetchFromGitHub {
          owner = "jbalme";
          repo = "user.js";
          rev = "76ba6f3c06c0884f4e05fb15388924262b69d6d6";
          sha256 = "sha256-LgU0Msllzc5SIY2JV4SWUCSk2Z4cmHNm0xk/8slYNpc=";
        };
      in builtins.readFile "${userjs}/user.js";
    };
  };
  home.sessionVariables.BROWSER = "firefox";

  # terminal
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      window.dynamic_title = true;
      font.size = 10;
    };
  };
  home.sessionVariables.TERMINAL = "alacritty";

  # editor
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = 
    let
      ext = pkgs.vscode-utils.buildVscodeMarketplaceExtension;
      asvetliakov.vscode-neovim = ext {
        mktplcRef = {
          name = "vscode-neovim";
          publisher = "asvetliakov";
          version = "0.0.78";
          sha256 = "sha256-dyXuMITHoLZBOYtLo4Jknf4TkeCysiNGQWkqxMPlfyg=";
        };
      };

      ms-dotnettools.csharp2 = ext {
        mktplcRef = {
          name = "csharp";
          publisher = "ms-dotnettools";
          version = "1.23.9";
          sha256 = "sha256-5G3u3eqzaqP794E/i7aj4UCO6HAifGwnRKsVaFT3CZg=";
        };
      };
      redhat.java = ext {
        mktplcRef = {
          name = "java";
          publisher = "redhat";
          version = "0.75.0";
          sha256 = "sha256-cXjCndW1izhKAMARIFQv45Ar8tZds+rZiRYvIZiIzyo=";
        };
      };
    in
    with pkgs.vscode-extensions;
    [
      #asvetliakov.vscode-neovim
      #ms-dotnettools.csharp
      #vscodevim.vim
      #bbenoist.Nix 
      #ms-python.vscode-pylance
      #redhat.vscode-yaml
      #redhat.java
      #matklad.rust-analyzer
    ];

    userSettings = rec {
      vscode-neovim.neovimExecutablePaths.linux = "${pkgs.neovim-git}/bin/nvim";
      omnisharp.path = "${pkgs.omnisharp-roslyn}/bin/omnisharp";
      java = {
        home = "${pkgs.jdk11}";
        configuration.runtimes = [
          {
            name = "JavaSE-1.8";
            path = "${pkgs.jdk8}";
          }
        ];
        project.importOnFirstTimeStartup = "automatic";
      };
      spring-boot.ls.java.home = java.home;
      maven.executable.path = "${pkgs.maven}/bin/mvn";
      files.exclude = {
        "**/.classpath" = true;
        "**/.project" = true;
        "**/.settings" = true;
        "**/.factorypath" = true;
      };
      editor.suggestSelection = "first";
      workbench.colorTheme = "Gruvbox Dark Medium";
      editor.fontFamily = "'Fira Code', 'monospace'";
      editor.fontLigatures = "true";
    };
  };

  home.sessionVariables.EDITOR = "code -w";
  home.sessionVariables.SUDO_EDITOR = "code -w";
  home.sessionVariables.GIT_EDITOR = "code -w";

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "awesomepanda";
    };
    enableCompletion = true;
  };

  # direnv
  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

  # media player
  programs.mpv = { enable = true; };

  # status bar
 # services.dwm-status = {
 #   enable = true;
 #   order = [ "time" ];
 #   package = pkgs.dwm-status.overrideAttrs (super: rec {
 #     name = "dwm-status-git";
 #     version = "12474e948d72ca102bb8e35b2769c53e9c9f7ec4";
 #     src = pkgs.fetchFromGitHub {
 #       owner = "Gerschtli";
 #       repo = "dwm-status";
 #       rev = version;
 #       sha256 = "1a3dpawxgi8d2a6w5jzvzm5q13rvqd656ris8mz77gj6f8qp7ddl";
 #     };
 #     cargoSha256 = "sha256-z434tTQcl+DjMXdF7jeHvLpNHmmM5eCDijEEk1eLbgg=";
 #     cargoDeps = super.cargoDeps.overrideAttrs (lib.const {
 #       name = "${name}-vendor.tar.gz";
 #       inherit src;
 #       outputHash = cargoSha256;
 #     });
 #   });
 # };

  # status bar
  services.dwm-status = {
    enable = true;
    order = [ "time" ];
    # hack until dwm-status is fixed
    package = pkgs.writeShellScriptBin "dwm-status" ''
      while true; do
        ${pkgs.xorg.xsetroot}/bin/xsetroot -name "$(printf '%(%F %R)T')";
        read -rt $((60-10#$(printf '%(%S)T')%60)) <> <(:) || :
      done
    '';
  };

  # applets
  services.network-manager-applet.enable = true;
  services.pasystray.enable = true;
  services.cbatticon.enable = true;

  # wm
  xsession.enable = true;
  xsession.windowManager.command = let
    dwm = pkgs.dwm.overrideAttrs (oa: {
      src = pkgs.fetchFromGitHub {
        owner = "jbalme";
        repo = "dwm";
        rev = "2e8028bcfda24bf430dc5d73a1987097fc0cc87d";
        sha256 = "sha256-uKTvxlQaJEDQpwiND3/7I8YjqsfHew+zml7QilPUuvw=";
      };
    });
  in "${dwm}/bin/dwm";

  # autostart
  xsession.initExtra = with pkgs; ''
    #${mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1 &
    #${blueman}/bin/blueman-tray &
    #${discord}/bin/Discord --start-minimized &
    #${element-desktop}/bin/element-desktop --hidden &
    #${steam}/bin/steam -silent &
    ${dex}/bin/dex --autostart
  '';

  manual.manpages.enable = false;
}
