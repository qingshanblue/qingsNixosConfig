# 程序：nix-ld、AppImage、Steam、Wireshark。

{ config, pkgs, ... }:

{
  # ---------- Nix-ld (用于运行预编译二进制) ----------
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib zstd stdenv.cc.cc.lib glib libGL libxkbcommon fontconfig libxshmfence freetype wayland libxcb-cursor libxcb-image libxcb-keysyms libxcb-render-util libxcb-wm libx11 libxext libxi libxrender fuse3 libxrandr libxcursor libxcomposite libxdamage libxfixes libxcb dbus  webkitgtk_4_1 gtk3 glib-networking gdk-pixbuf cairo pango libsoup_3
    ];
  };

  programs.appimage = {
  enable = true;
  binfmt = true;
  # 使用 override 添加额外的依赖包
  package = pkgs.appimage-run.override {
    extraPkgs = pkgs: with pkgs; [
      libepoxy libgpg-error
      # 可以继续添加其他缺失的库，如 python312 等
    ];
  };
};

  programs.wireshark = {  
    enable = true;
    package = pkgs.wireshark;
    dumpcap.enable = true;
    usbmon.enable = true;
  };

  # ---------- Steam ----------
  programs.steam = {
    enable = true;
    package = pkgs.steam.override { extraEnv = { GDK_SCALE = "2"; }; };
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
