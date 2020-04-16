# vim: expandtab:ts=2:sw=2:nowrap

# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "screw-loose";
  # networking.wireless.enable = true;  # Enables wpa_supplicant.
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # System packages go here
  ];
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = true;

  # home-manager settings
  home-manager.useUserPackages = true;

  # This is disabled for configuration of suckless terminal
  # todo: work out how to configure a global package for a user
  #home-manager.useGlobalPkgs = true;

  # Home manager workaround for https://github.com/rycee/home-manager/issues/948
  systemd.services.home-manager-tobin.preStart = ''${pkgs.nix}/bin/nix-env -iE'';

  # Configure users
  users.mutableUsers = false;
  users.users.tobin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "hello";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvDbFWOid6hqQxKQAKylsmOhEZU7fyO7+UgywT4Sw7MtCv2z9kgoQ/sOnxe7Vqiiau7d2OM8rXWVWCTkP27UK8OrXxjyJNTyfxK6vMVk+/Y8yaB5fJRebbkJ0K7K0WnLWuA7mSy7Jb3Kx4toMM8P+EzFvks/spLKN3C7/h+gOE8x2miwJCnGKvVipN9ZmZntwexsZT4t14ts3+goAvgzu+xH35u2X02OwBmDeLTlIxLlZaOimlQwRw/x4lqyTx/YNCludM3CBSWidLvGfuTwQ4H+KCyHDgkA+NwY2GM/aItiq1BGijqEBdUHPPB5O4lyqp4qoGcLDth6Q6KCaWVg4n tobin@bsl10408-lin" ];
  };

  # Set up users home with home-manager
  home-manager.users.tobin = {pkgs, ... }: {


    home.packages = [
      pkgs.tmux
      pkgs.st
      pkgs.fira-code
      pkgs.chromium
    ];

    # Only because we aren't using global packages
    nixpkgs.config.allowUnfree = true;

    # X Session with i3 window manager
    xsession.enable = true;
    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      config = {
        modifier = "Mod4";
        terminal = "st";
      };
    };

    xresources.properties = {
      "Xft.dpi" = 192;
    };

    # Configure suckless terminal (happens at build-time)
    # Note, this is blocking using "useGlobalPkgs"
    nixpkgs.config.st = {
        conf = builtins.readFile ./st-config.h;
        patches = [./st-ligatures-20200406-28ad288.diff];
        extraLibs = [pkgs.harfbuzz];
    };

    # Git
    programs.git = {
      enable = true;
    };

    # ZShell
    programs.zsh = {
      enable = true;
      autocd = true;
      history.share = true;
      plugins = [
        {
          name = "agkozak-zsh-prompt";
          src = pkgs.fetchFromGitHub {
            owner = "agkozak";
            repo = "agkozak-zsh-prompt";
            rev = "v3.7.1";
            sha256 = "0kq7qvwkbkx18k4wxcnc76xnsrfn32k8dykvrsmmz8y9f81zhnpz";
          };
        }
      ];
      oh-my-zsh = {
        enable = true;
      };
    };

    # VIM
    programs.vim = {
      enable = true;
      plugins = [pkgs.vimPlugins.vim-sensible pkgs.vimPlugins.base16-vim];
      settings = {modeline = true;};
    };

  
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

