# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";

in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];

  # bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs;
      [
        vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable
        # mesa
        # onevpl-intel-gpu  # for newer GPUs on NixOS <= 24.05
        # intel-media-sdk   # for older GPUs
      ];
  };
  boot.kernelParams = [ "i915.force_probe=46a8" ];

  # ------------------------------------------------------------------------
  # Boot Loader
  # ------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ------------------------------------------------------------------------
  # Networking
  # ------------------------------------------------------------------------
  networking = {
    # sshd.enable = true;
    hostName = "cybergaz";

    # wireless network interfaces.
    wireless.iwd.enable = true;
    wireless.iwd.settings = {
      IPv6 = { Enabled = true; };
      Settings = { AutoConnect = true; };
    };

    # wired network interface. ( Replace enp0s20f0u5 with your interface name )
    # interfaces.enp0s20f0u5.useDHCP = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.firewall.enable = false;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gaz = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  services.displayManager.ly.enable = true;
  services.displayManager.ly.settings = {
    # matrix || none
    animation = "matrix";
    # The character used to mask the password
    asterisk = ".";
    # Erase password input on failure
    clear_password = true;
    # Remove main box borders
    hide_borders = true;
    # Main box margins
    margin_box_h = 2;
    margin_box_v = 1;
    # Input boxes length
    input_len = 34;
  };

  # programs.firefox.enable = true;
  programs.hyprland.enable = true;
  programs.niri.enable = true;
  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    git
    vim
    tmux
    wget
    neovim
    alacritty
    kitty
    waybar
    libnotify
    mako
    greetd.tuigreet
    ly
    firefox-bin
    wofi
    btop
    rustup
    glib
    libgcc
    zig
    bun
    nodejs
    zip
    ripunzip
    gcc
    ripgrep
    wl-clipboard
    cliphist
    iwgtk
    nemo
    brightnessctl
    hyprlock
    hyprpicker
    xwayland-satellite
    google-chrome
    lyra-cursors
    layan-gtk-theme
    kora-icon-theme
    grim
    slurp
    cloudflare-warp
    zoxide
    mpv
    code-cursor
    neofetch
    swww
    viewnior
    dust
    gnome.gvfs
    neovide
    aria2
    usbutils
    tmate
  ];

  environment.localBinInPath = true;
  # environment.pathsToLink =
  #   [ "/" "~/.cargo/bin" "~/.bun/bin" "~/.local/share/nvim/mason/bin" ];
  environment.variables = {
    # Set the default editor.
    EDITOR = "nvim";
    TERMINAL = "alacritty";
    FILE_MANAGER = "nemo";
    OZONE_WL = "1"; # Enable ozone wayland support for chromium
    PATH = "$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin";
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "joypixels" ];
  nixpkgs.config.joypixels.acceptLicense = true;

  fonts.packages = with pkgs; [
    comfortaa
    jetbrains-mono
    noto-fonts
    twemoji-color-font
    joypixels
    noto-fonts-emoji-blob-bin
    noto-fonts-monochrome-emoji
    nerd-fonts.noto
  ];

  home-manager.users.gaz = { pkgs, ... }: {
    programs.bash.enable = true;
    home.packages = [ pkgs.atool pkgs.httpie ];

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.05";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.

  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
    HandlePowerKeyLongPress=poweroff
    HandleLidSwitch=ignore
    HandleLidSwitchExternalPower=ignore
    HandleLidSwitchDocked=ignore
  '';

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
