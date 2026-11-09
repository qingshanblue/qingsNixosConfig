# 日常桌面应用程序、系统管理工具、办公、IM 与多媒体软件。

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ---------- 系统与桌面小工具 ----------
    dig
    mtr
    glib
    wget
    xdg-user-dirs
    busybox
    neovim
    kitty
    nemo
    wl-clipboard
    hardinfo2
    playerctl
    elephant
    walker
    libnotify
    brightnessctl
    ddcutil
    dotnet-runtime
    kdePackages.ark
    hyprpolkitagent
    hyprpaper
    hyprshot
    hyprpicker
    hyprlock
    hypridle
    hyprshutdown
    hyprsunset
    hyprsysteminfo
    hyprland-qt-support
    fastfetch
    qt6Packages.fcitx5-configtool
    mission-center
    adwaita-icon-theme
    papirus-icon-theme
    pavucontrol
    blueman
    bluez-tools
    ouch
    fd
    iptables
    ncdu
    smartmontools
    podman-compose
    podman-desktop
    kubectl
    gparted

    # ---------- 浏览器与视听 ----------
    google-chrome
    firefox
    celluloid
    swayimg
    openlist
    scrcpy
    go-musicfox

    # ---------- 社交通讯与日常办公 ----------
    qq
    telegram-desktop
    wechat
    wpsoffice-cn
    libreoffice
    obsidian
    /* zotero */
    kdePackages.okular

    # ---------- Sing-box 客户端包装 ----------
    (gui-for-singbox.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ makeWrapper ];
      postInstall = (old.postInstall or "") + ''
        wrapProgram $out/bin/GUI.for.SingBox \
          --set __NV_DISABLE_EXPLICIT_SYNC 1
      '';
    }))

    # ---------- 下载工具 (含证书修复) ----------
    ## 修复 HTTPS 下载报 "unable to get local issuer certificate (20)"：
    # rayburst 捆绑的预编译引擎 aria2-next（上游 Ubuntu CI 编译）把 CA 证书库
    # 路径硬编码为 FHS 路径，NixOS 上不存在，导致 TLS 验证失败。
    # 应用侧无解：Rayburst 每次启动重写 engine/aria2.conf，且其 aria2 选项
    # 白名单（src/shared/aria2Options.json）不含 ca-certificate。
    # 故用 wrapper 给引擎追加命令行参数（命令行优先级高于 conf，免疫重写）。
    # 待 nixpkgs/rayburst 上游修复后可整体删除本 override。
    (rayburst.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/aria2-next \
          --add-flags "--ca-certificate=/etc/ssl/certs/ca-certificates.crt"
      '';
    }))
  ];
}
