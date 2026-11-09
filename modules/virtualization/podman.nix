# 容器运行时：Podman（rootful，供 oci-containers 使用与命令行管理）。

{ config, pkgs, ... }:

{
  environment.etc."containers/registries.conf".text = ''
    unqualified-search-registries = ["docker.io"]
  '';

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
