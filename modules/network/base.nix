# 网络基础设施：主机名、NetworkManager、IPv4 优先、Avahi mDNS 与基础防火墙。

{ config, pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # getaddrinfo IPv4 优先（RFC 6724 排序覆盖）
  networking.getaddrinfo.precedence = {
    "::ffff:0:0/96" = 100;
  };

  # ---------- Avahi 服务发现 ----------
  services.avahi = {
    enable = true;
    settings.publish = {
      "disable-publishing" = false;
      "disable-user-service-publishing" = false;
      "publish-addresses" = true;
    };
  };

  # ---------- 基础防火墙开启 ----------
  networking.firewall.enable = true;
}
