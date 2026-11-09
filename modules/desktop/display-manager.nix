# 登录管理器：SDDM (Wayland) 及默认会话、自动登录。

{ config, pkgs, ... }:

{
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "hyprland-uwsm";
    autoLogin = {
      enable = true;
      user = "qings";
    };
  };
}
