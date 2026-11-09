# 代理环境与 Sing-box：系统代理环境变量、Proxychains、sing-box 宿主 WebUI 服务与防火墙放行。

{ config, pkgs, ... }:

{
  # 系统服务全局代理环境变量
  systemd.globalEnvironment = {
    http_proxy  = "http://127.0.0.1:20122";
    https_proxy = "http://127.0.0.1:20122";
    all_proxy   = "socks5://127.0.0.1:20122";
    no_proxy    = "localhost,127.0.0.1,::1";
  };

  # ---------- Proxychains 终端代理 ----------
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

  # ---------- WEBUI for SingBox 宿主后台服务 ----------
  systemd.services.webui-for-singbox = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "qings";
      ExecStart = "/home/qings/.local/share/webui-for-singbox/webui.for.singbox";
      WorkingDirectory = "/home/qings";
      Restart = "on-failure";
      RestartSec = 3;
      AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
    };
  };

  # ---------- 代理与 Sing-box 相关端口放行 ----------
  networking.firewall.allowedTCPPorts = [ 20122 ];
  networking.firewall.allowedUDPPorts = [ 20122 ];
}
