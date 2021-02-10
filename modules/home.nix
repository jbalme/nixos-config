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
    engrampa
    caja-with-extensions
    atril
    eom
    mate-calc

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
    package = pkgs.vscodium;
  };

  home.sessionVariables.EDITOR = "codium";
  home.sessionVariables.SUDO_EDITOR = "codium -w";

  # shell
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
  services.dwm-status = {
    enable = true;
    order = [ "time" ];
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
    ${mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1 &
    ${blueman}/bin/blueman-tray &
    ${discord}/bin/Discord --start-minimized &
    ${element-desktop}/bin/element-desktop --hidden &
    ${steam}/bin/steam -silent &
  '';
}
