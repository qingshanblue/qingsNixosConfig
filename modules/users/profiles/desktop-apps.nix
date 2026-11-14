# 日常桌面应用程序、系统管理工具、办公、IM 与多媒体软件。

{ config, pkgs, ... }:

let
  # ---------- 带 VA-API 开关的 Chrome ----------
  # 驱动层（nvidia-vaapi-driver）已就绪，但 Chrome 还需要 feature flag 才会启用 VA-API；
  # 而 Chrome 156 的二进制里没有 *flags.conf 支持，flag 只能由包装脚本提供。
  # 这里用 symlinkJoin + makeWrapper 把 flag 注入启动器，并同步改写 .desktop 的 Exec，
  # 让菜单/launcher（walker/elephant）启动的也是带 flag 的那个。
  google-chrome-vaapi = pkgs.symlinkJoin {
    name = "google-chrome-vaapi";
    paths = [ pkgs.google-chrome ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # NVIDIA 上启用 VA-API 所需的一组 feature flag（AcceleratedVideoDecodeLinux* 是
      # 新版 Chrome 里 VaapiVideoDecoder 的替身，VaapiOnNvidiaGPUs 才允许走 NVIDIA 驱动）
      wrapProgram $out/bin/google-chrome-stable \
        --add-flags "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiOnNvidiaGPUs,VaapiIgnoreDriverChecks" \
        --add-flags "--ignore-gpu-blocklist"

      # symlinkJoin 输出里的 .desktop 是指向原包的符号链接，直接改会写穿到只读 store；
      # 因此先删掉再重新生成，把 Exec 指向带 flag 的启动器。
      for f in $out/share/applications/*.desktop; do
        src="${pkgs.google-chrome}/share/applications/$(basename "$f")"
        rm -f "$f"
        sed -e "s|${pkgs.google-chrome}/bin/google-chrome-stable|$out/bin/google-chrome-stable|g" \
            "$src" > "$f"
      done
    '';
  };
in
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
    nemo-with-extensions
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
    # 需要原版（不带 flag）对比测试时，把 google-chrome-vaapi 换成 google-chrome 即可
    google-chrome-vaapi
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
