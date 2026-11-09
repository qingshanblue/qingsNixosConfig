# 网络：主机名、NetworkManager、防火墙、Tailscale、Avahi、代理。

{ config, pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # getaddrinfo IPv4 优先（RFC 6724 排序覆盖）
  networking.getaddrinfo.precedence = {
    "::ffff:0:0/96" = 100;
  };

  # 系统服务环境变量 
  systemd.globalEnvironment = {
     http_proxy  = "http://127.0.0.1:20122";
     https_proxy = "http://127.0.0.1:20122";
     all_proxy   = "socks5://127.0.0.1:20122";
     no_proxy    = "localhost,127.0.0.1,::1";
  };

  services.avahi = {
    enable = true;
    settings.publish = {
      "disable-publishing" = false;
      "disable-user-service-publishing" = false;
      "publish-addresses" = true;
    };
  };

  programs.proxychains = {
    enable = true;
    proxies = {
      localProxy = {
        type = "socks5";
        host = "localhost";
        port = "20122";
      };
    };
  };

  # ---------- Tailscale 组网 ----------
  services.tailscale = {
    enable = true;
    openFirewall = true;  # 放行 UDP 41641，提高打洞直连成功率
  };

  # ---------- 防火墙 ----------
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 2222 20122 ];
    allowedUDPPorts = [ 20122 ];
  };
}
