# 游戏运行环境、模拟器与娱乐配置。

{ config, pkgs, ... }:

let
  wrappers = import ../../../lib/wrappers.nix { inherit pkgs; };
  inherit (wrappers) mkScaled;
in
{
  # ---------- Steam 运行时 ----------
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv = {
        GDK_SCALE = "2";
      };
    };
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # ---------- 游戏客户端与辅助工具 ----------
  environment.systemPackages = with pkgs; [
    steam-run
    protonup-rs
    bottles
    olympus
    osu-lazer
    prismlauncher

    # HMCL (Minecraft 启动器)
    # HMCL 是 JavaFX（XWayland）。JavaFX 支持分数缩放：HMCL 会把 HMCL_UI_SCALE
    # 转成 glass.gtk.uiScale。实测 1.6 真的生效（日志 Screen 1: 2560x1440 @1.6x，
    # 逻辑 1600x900），字与控件都清晰。也接受 160% / 154dpi 写法。
    (mkScaled "hmcl-scaled" hmcl "hmcl" "--set HMCL_UI_SCALE 1.6")
  ];
}
