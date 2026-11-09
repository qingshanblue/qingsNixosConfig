# 桌面：Hyprland、SDDM 登录、XDG Portal 与 Flatpak、dux-shell、桌面基础服务、Sunshine。

{ config, pkgs, ... }:

{
  # ---------- Flatpak 与 Portal ----------
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # ---------- 桌面环境 ----------
  # services.desktopManager.plasma6.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # ---------- Sunshine  ----------
  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = false;
    openFirewall = true;
    settings.port = 47989;
  };

  # ---------- 登录管理器 ----------
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

  programs.dux-shell = {
    enable = true;
    systemd = {
      enable = true;             # Systemd service for auto-start
      restartIfChanged = true;   # Auto-restart dms.service when dms-shell changes
    };
  };

  # ---------- 系统服务 ----------
  security.polkit.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;          
  services.elephant.enable = true;
  services.power-profiles-daemon.enable = true; 
  systemd.user.services.elephant.environment.PATH = pkgs.lib.mkForce "/run/wrappers/bin:/run/current-system/sw/bin:/etc/profiles/per-user/qings/bin:/home/qings/.nix-profile/bin:/home/qings/.local/share/flatpak/exports/bin:/var/lib/flatpak/exports/bin:${pkgs.bash}/bin";
}
