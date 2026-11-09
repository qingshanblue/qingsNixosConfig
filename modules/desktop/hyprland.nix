# 桌面合成器：Hyprland、uwsm、xdg-portal 与 dux-shell。

{ config, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # ---------- XDG Desktop Portal ----------
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # ---------- Dux Shell ----------
  programs.dux-shell = {
    enable = true;
    systemd = {
      enable = true;             # Systemd service for auto-start
      restartIfChanged = true;   # Auto-restart dms.service when dms-shell changes
    };
  };
}
