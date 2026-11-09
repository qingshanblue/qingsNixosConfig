# NixOS 顶层模块聚合入口：按领域清晰组织所有系统子模块

{ config, pkgs, ... }:

{
  imports = [
    # ---------- 系统核心 ----------
    ./core/nix.nix
    ./core/boot.nix
    ./core/locale.nix
    ./core/maintenance.nix

    # ---------- 硬件与驱动 ----------
    ./hardware/nvidia.nix
    ./hardware/audio.nix
    ./hardware/bluetooth.nix
    ./hardware/tuxedo.nix
    ./hardware/power.nix

    # ---------- 桌面环境 ----------
    ./desktop/hyprland.nix
    ./desktop/display-manager.nix
    ./desktop/base-services.nix
    ./desktop/sunshine.nix

    # ---------- 网络与代理 ----------
    ./network/base.nix
    ./network/proxy.nix
    ./network/tailscale.nix
    ./network/remote.nix

    # ---------- 虚拟化与容器 ----------
    ./virtualization/podman.nix
    ./virtualization/waydroid.nix
    ./virtualization/containers.nix

    # ---------- 用户与特定环境 ----------
    ./users/qings.nix
    ./users/profiles/dev.nix
    ./users/profiles/embedded.nix
    ./users/profiles/desktop-apps.nix
    ./users/profiles/gaming.nix
  ];
}
