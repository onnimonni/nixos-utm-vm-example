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

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMsvLc6BEB556NzZU0TarX9WkStle3+tFfvdFLZIco999VEYgnVBIdT37qaQlwhN5K8u+4KFe+P0MlQG7yGgd70= ecdsa-sha2-nistp256"
  ];

  system.stateVersion = "23.11";
}
