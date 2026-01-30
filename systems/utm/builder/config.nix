{ pkgs, nrnSSHKey, rootSSHKey, ... }:

{
  networking.hostName = "builder";

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  environment.systemPackages = [
    pkgs.vim
    pkgs.git
    pkgs.zip
    pkgs.unzip
    pkgs.wget
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];

  documentation.nixos.enable = false;
  time.timeZone = "Etc/UTC";
  i18n.defaultLocale = "nl_NL.UTF-8";
  console.keyMap = "us";
  nix.settings.trusted-users = [ "nrn" "@wheel" ];
  nix.settings.system-features = [ "kvm" "nixos-test" ];

  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
      };
    };
    kernelModules = [ "kvm-amd" "kvm-intel" ];
  };
  virtualisation.libvirtd.enable = true;

  users.users = {
    root.hashedPassword = "!"; # Disable root login
    nrn = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = "$6$100uihg8uvZQh3EL$VublcxWA77V.HxhPiyRoUBbk1EbjnqjDrD/a29jZf25rQgIFs2ZYG.LwcAZxa7AAzFEbduBQCRF5VdD7TpHlQ0";
      openssh.authorizedKeys.keys = [
        nrnSSHKey
        rootSSHKey
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
