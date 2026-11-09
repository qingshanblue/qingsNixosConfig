# 虚拟局域网：Tailscale 组网。

{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;  # 放行 UDP 41641，提高打洞直连成功率
  };
}
