# Sunshine 游戏串流主机服务。

{ config, pkgs, ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = false;
    openFirewall = true;
    settings.port = 47989;
  };
}
