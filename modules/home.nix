{ pkgs, lib, config, ... }:
with lib; {
  # for flake support
  home.stateVersion = "20.09";

  home.packages = with pkgs // pkgs.mate; [
    dmenu

    # communications
    zoom-us
    discord
    # element-desktop

    # vidya
    steam
    steam-run

    # volume control
    pavucontrol

    # services
    mate-notification-daemon
    mate-polkit

    # system
    htop
    ncdu

    # dotnet
    dotnet-sdk_5

    librecad
  ];

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
  programs.chromium = { enable = true; };

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
      in builtins.readFile "${pkgs.inputs.userjs}/user.js";
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
    extensions = with pkgs.vscode-extensions; [
      #asvetliakov.vscode-neovim
      ms-dotnettools.csharp
      vscodevim.vim
      bbenoist.Nix
      #ms-python.vscode-pylance
      #redhat.vscode-yaml
      #redhat.java
      #matklad.rust-analyzer
    ];

    userSettings = rec {
      # vscode-neovim.neovimExecutablePaths.linux = "${pkgs.neovim-git}/bin/nvim";
      omnisharp.path = "${pkgs.omnisharp-roslyn}/bin/omnisharp";
      java = {
        home = "${pkgs.jdk11}";
        configuration.runtimes = [{
          name = "JavaSE-1.8";
          path = "${pkgs.jdk8}";
        }];
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
      window = { titleBarStyle = "custom"; };
    };
  };

  home.sessionVariables.EDITOR = "code -w";
  home.sessionVariables.SUDO_EDITOR = "code -w";
  home.sessionVariables.GIT_EDITOR = "code -w";

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
  xsession.windowManager.command =
    let dwm = pkgs.dwm.overrideAttrs (oa: { src = pkgs.inputs.dwm; });
    in "${dwm}/bin/dwm";

  # autostart
  xsession.initExtra = with pkgs; ''
    ${dex}/bin/dex --autostart
  '';

  manual.manpages.enable = false;


}
