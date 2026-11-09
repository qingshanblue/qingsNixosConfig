# 系统服务：sshd、cron、sing-box WebUI。

{ config, pkgs, ... }:

{
  # ---------- 定时任务 ----------
  services.cron = {
    enable = true;
    systemCronJobs = [
      "00 01 * * * root /run/current-system/sw/bin/shutdown -h +3 \"System auto shutdown in 3 minutes...\""
    ];
  };

  # ---------- SSH 服务 ----------
  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
  };

  # ---------- WEBUI for SingBox ----------
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
}
