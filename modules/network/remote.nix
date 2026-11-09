# 远程访问：SSH 服务、认证策略与防火墙放行。

{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 2222 ];
}
