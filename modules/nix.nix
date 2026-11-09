# Nix 本身：设置与镜像源、垃圾回收、nixpkgs 许可。

{ config, pkgs, ... }:

{
  # ---------- 垃圾回收与存储优化 ----------
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "";
  };
  # 每次自动回收前只保留最近 5 代系统代数（"-" 前缀：失败不阻断 GC）
  systemd.services.nix-gc.serviceConfig.ExecStartPre = [
    "-${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +5"
  ];

  nixpkgs.config.allowUnfree = true;

  # ---------- Nix 设置与镜像源 ----------
  nix.settings = {
    substituters = [
      "https://mirrors.cernet.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHbD9b2j5Tum1L0A8qhcJ9wUpN4Lo2RnBS4a4s4O0="
    ];
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # 包留Wrapper导致的编译
    keep-derivations = true;
  };
}
