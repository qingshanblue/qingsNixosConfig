# 桌面基础守护进程与后台服务：Polkit、GVFS、UDisks2、UPower、Flatpak、Elephant。

{ config, pkgs, ... }:

{
  security.polkit.enable = true;
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # ---------- Elephant 桌面索引/启动器后台 ----------
  services.elephant.enable = true;
  systemd.user.services.elephant.environment.PATH = pkgs.lib.mkForce (
    "/run/wrappers/bin:/run/current-system/sw/bin:" +
    "/etc/profiles/per-user/qings/bin:/home/qings/.nix-profile/bin:" +
    "/home/qings/.local/share/flatpak/exports/bin:/var/lib/flatpak/exports/bin:" +
    "${pkgs.bash}/bin"
  );
}
