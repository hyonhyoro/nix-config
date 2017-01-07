{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelModules = [ "msr" "coretemp" "fuse" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.pathsToLink = [ "/include" "/share" ];
  environment.shellInit = ''
    ## GTK2 theme/icon
    export GTK_PATH=$GTK_PATH:${pkgs.gtk-engine-murrine}/lib/gtk-2.0
    export GTK2_RC_FILES=$GTK2_RC_FILES:${pkgs.writeText "iconrc" ''gtk-icon-theme-name="Numix Circle"''}:${pkgs.arc-theme}/share/themes/Arc/gtk-2.0/gtkrc

    ## GTK3 theme
    export GTK_THEME="Arc"

    ## Rust
    export RUST_SRC_PATH="${pkgs.rustPlatform.rust.rustc.src}/src"
  '';
  environment.systemPackages = with pkgs; [
    ### xorg
    xorg.xmodmap
    xcape
    xclip
    xdo

    ### gtk
    gtk2
    gtk3
    gtk_engines
    gtk-engine-murrine
    hicolor_icon_theme
    arc-theme
    numix-icon-theme-circle
    ### android
    androidenv.platformTools
    gitRepo

    ### tools
    ## emacs
    emacs
    aspell
    aspellDicts.en
    yaskkserv
    ctags
    rtags
    ## git
    gitAndTools.gitFull
    gitAndTools.tig
    ## mpd
    mpc_cli
    ncmpcpp
    ## download
    curl
    wget
    aria2
    megatools
    ## misc
    asunder
    bc
    exfat
    extundelete
    feh
    ffmpeg
    file
    firefoxWrapper
    fuse
    gucharmap
    htop
    id3v2
    imagemagick
    lsof
    mcomix
    mpv
    nix-repl
    nkf
    p7zip
    ranger
    rofi
    rxvt_unicode-with-plugins
    screenfetch
    scrot
    silver-searcher
    telnet
    tree
    unar
    unrar
    unzipNLS
    vim
    w3m
    which
    wrk
    yabar
    zip

    ### languages
    ## c/c++
    llvmPackages.llvm
    llvmPackages.clang
    gnumake
    cmake
    bear
    ccache
    gdb
    cpputest
    ## rust
    rustPlatform.rust.rustc
    rustPlatform.rust.cargo
    rustracer
    rustfmt
    ## python
    (python34.buildEnv.override {
      extraLibs = with python34Packages; [
        ipython
        jupyter
        virtualenv
        ipdb
        coverage
        flake8
        jedi
        epc
        importmagic
        yapf
      ];
      ignoreCollisions = true;
    })
  ];

  fonts.fonts = with pkgs; [
    anonymousPro
    camingo-code
    dejavu_fonts
    font-awesome-ttf
    inconsolata
    source-code-pro
    terminus_font
  ];

  hardware.opengl.driSupport32Bit = true;

  i18n.consoleFont = "lat9w-16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod.enabled = "uim";

  networking.firewall.allowedTCPPorts = [ 80 443 6600 8000 ];
  networking.firewall.enable = false;
  networking.hostName = "nixos";
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  nix.binaryCaches = [ "https://cache.nixos.org" ];
  nix.extraOptions = ''
    auto-optimise-store = true
    env-keep-derivations = true
    gc-keep-outputs = true
    gc-keep-derivations = true
  '';
  nix.nixPath = [
    "nixpkgs=/etc/nixos/nixpkgs"
    "nixos=/etc/nixos/nixpkgs/nixos"
    "nixos-config=/etc/nixos/configuration.nix"
  ];
  nix.useSandbox = true;

  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.firefox.enableAdobeFlash = true;
  nixpkgs.config.packageOverrides = pkgs: {
    yaskkserv = pkgs.callPackage ./custom/yaskkserv { };

    ncmpcpp = pkgs.ncmpcpp.override {
      outputsSupport = true;
      visualizerSupport = true;
      clockSupport = true;
    };
  };

  powerManagement.enable = true;

  programs.bash.enableCompletion = true;

  services.mpd.enable = true;
  services.mpd.extraConfig = ''
    audio_output {
      type       "alsa"
      name       "alsa_device"
      format     "44100:16:2"
      mixer_type "software"
    }

    audio_output {
      type   "fifo"
      name   "my_fifo"
      path   "/tmp/mpd.fifo"
      format "44100:16:2"
    }

    audio_output {
      type    "httpd"
      name    "my_http_stream"
      encoder "vorbis"
      port    "8000"
      bitrate "128"
      format  "44100:16:1"
    }
  '';
  services.mpd.group = "users";
  services.mpd.user = "hyonhyoro";
  services.mpd.musicDirectory = "/home/hyonhyoro/Music";

  services.ntp.enable = true;
  services.ntp.servers = [
    "ntp.nict.jp"
    "ntp1.jst.mfeed.ad.jp"
    "ntp2.jst.mfeed.ad.jp"
    "ntp3.jst.mfeed.ad.jp"
  ];

  services.openssh.enable = true;
  services.printing.enable = true;
  services.udev.packages = [ pkgs.android-udev-rules ];
  services.unclutter.enable = true;

  services.xserver = {
    enable = true;
    autorun = true;

    desktopManager.default = "none";
    desktopManager.xterm.enable = false;

    displayManager.lightdm.enable = true;

    videoDrivers = [ "nvidia" ];

    windowManager.bspwm.enable = true;
    windowManager.default = "bspwm";
  };

  sound.enable = true;
  sound.enableOSSEmulation = true;
  sound.extraConfig = ''
    pcm.dsp {
      type plug
      slave.pcm "dmix"
    }
  '';

  time.timeZone = "Asia/Tokyo";

  users.defaultUserShell = pkgs.bash;
  users.extraUsers = {
    hyonhyoro = {
      uid = 1000;
      isNormalUser = true;
      createHome = true;
      extraGroups = [ "audio" "fuse" "networkmanager" "wheel" ];
    };
  };

  system.stateVersion = "17.03";
}
