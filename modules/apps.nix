# 图形应用、桌面工具与游戏软件包。mkScaled 来自 packages.nix。

{ config, pkgs, mkScaled, ... }:

{
  environment.systemPackages = with pkgs; [
    # System & Desktop
    dig mtr glib wget xdg-user-dirs busybox neovim kitty nemo
    wl-clipboard hardinfo2 playerctl
    elephant walker libnotify brightnessctl ddcutil
    dotnet-runtime
    kdePackages.ark hyprpolkitagent hyprpaper hyprshot hyprpicker hyprlock
    hypridle hyprshutdown hyprsunset hyprsysteminfo hyprland-qt-support
    fastfetch qt6Packages.fcitx5-configtool mission-center
    adwaita-icon-theme papirus-icon-theme 
    pavucontrol blueman bluez-tools google-chrome firefox
    vscode.fhs celluloid swayimg steam-run
    ouch fd iptables ncdu smartmontools podman-compose kubectl

    # User Apps
    openlist
    (gui-for-singbox.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ makeWrapper ];
      postInstall = (old.postInstall or "") + ''
        wrapProgram $out/bin/GUI.for.SingBox \
          --set __NV_DISABLE_EXPLICIT_SYNC 1
      '';
    }))
    #YesPlayMusic
    scrcpy go-musicfox 
    qq telegram-desktop
    wechat
    wpsoffice-cn libreoffice podman-desktop gparted
    obsidian /* zotero */ kdePackages.okular
    ## 修复 HTTPS 下载报 "unable to get local issuer certificate (20)"：
    # rayburst 捆绑的预编译引擎 aria2-next（上游 Ubuntu CI 编译）把 CA 证书库，
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

    # Games
    protonup-rs bottles olympus osu-lazer prismlauncher
    # HMC L 是 JavaFX（XWayland）。JavaFX 支持分数缩放：HMCL 会把 HMCL_UI_SCALE
    # 转成 glass.gtk.uiScale。实测 1.6 真的生效（日志 Screen 1: 2560x1440 @1.6x，
    # 逻辑 1600x900），字与控件都清晰。也接受 160% / 154dpi 写法。
    (mkScaled "hmcl-scaled" hmcl "hmcl" "--set HMCL_UI_SCALE 1.6")
  ];

}
