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
  home.sessionVariables.BROWSER = "firefox";

  programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
      browserpass
    ];
    profiles.default = {};

  };

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
    plugins = [{
      name = "zsh-nix-shell";
      file = "nix-shell.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "chisui";
        repo = "zsh-nix-shell";
        rev = "v0.1.0";
        sha256 = "0snhch9hfy83d4amkyxx33izvkhbwmindy0zjjk28hih1a9l2jmx";
      };
    }];
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
        rev = "9dcd0c4b84285fa5ae8377b81a0c1b1aee474e08";
        sha256 = "sha256-SXdhXS07FwodCXcA2ciKNp5K5sZY2el2dFy/TnxNNf0=";
      };
    });
  in "${dwm}/bin/dwm";

  # autostart
  xsession.initExtra = with pkgs; ''
    ${mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1 &
    ${discord}/bin/Discord --start-minimized &
    ${element-desktop}/bin/element-desktop --hidden &
    ${steam}/bin/steam -silent &
  '';
}
