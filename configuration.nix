{
  modulesPath,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  networking.hostName = "utm-vm-nixos-builder";

  services = {
      avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
          publish = {
              enable = true;
              userServices = true;
              addresses = true;
          };
      };
  };

  virtualisation.rosetta.enable = true;
  
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQFdTlBtfe0pgFoyhCXgEIuV8p4j0bv6S0mxKexDWkA onnimonni@utm-vm-nixos-builder"
  ];

  system.stateVersion = "23.11";
}
