{ pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./services/mail.nix
    ./services/babelmark.nix
    ./services/borowski.nix
    ./services/grafana.nix
    ./services/nextcloud.nix
    ./services/pastebinrun.nix
    ./services/quassel.nix
    ./services/sandbox.nix
    ./services/xbot.nix
    ./services/xfix.nix
    ./services/zfsbackup.nix
    <nixpkgs/nixos/modules/profiles/headless.nix>
  ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      "i.xfix.pw" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/lib/nextcloud/data/xfix/files/i.xfix.pw";
      };
    };
  };

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    monthly = 1;
  };

  users.users.xfix = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+WycvjAdoGNNCLNSlu/Tr3wiiX/u57WORMJLJS5I0S"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ7GBke6Y5m3z4VtiQPzQjVGnPLi6/XwFMNuNtVnL6vM"
    ];
  };

  environment.systemPackages = [ pkgs.htop pkgs.git ];
  programs.fish.enable = true;

  zramSwap.enable = true;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };
}
