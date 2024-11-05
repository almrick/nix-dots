{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
 
  # Kernel
  boot.kernelPackages = pkgs.linuxPackages;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network
  networking.hostName = "cave";
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "Europe/London";

  # Locale & Console keymap & Console font
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  # Xfce
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = "xfce";
  
  # Services
  services = {
    mullvad-vpn.enable = true;
    printing.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };

  # User account
  users.users.almrick = {
    isNormalUser = true;
    createHome = true;

    extraGroups = [
      "networkmanager" 
      "wheel" 
    ];

    packages = with pkgs; [
      # Programing
      clang
      lldb
      cmake
      git
      # Internet things
      librewolf
      mullvad-vpn
      qbittorrent
      # Media
      milkytracker
      # Emacs
      emacs-gtk
    ];
  };

  # Packages
  environment.systemPackages = with pkgs; [];

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "-d";
    };

    settings.experimental-features = [
      "nix-command" 
      "flakes" 
    ];
  };

  system.stateVersion = "unstable";
}
