# 网络基础设施：主机名、NetworkManager、IPv4 优先、Avahi mDNS 与基础防火墙。

{ config, pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # 明确声明无线网卡接口，防止 NixOS 默认生成在早期阶段阻塞执行的 try-restart wpa_supplicant udev 规则
  networking.wireless.interfaces = [ "wlp4s0" ];

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
