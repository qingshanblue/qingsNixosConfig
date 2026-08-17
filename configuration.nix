{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Singapore";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  # ---------- 自动垃圾回收与引导菜单优化 ----------
  nix.gc = {
    automatic = true;
    dates = "weekly";            # 每周自动清理一次
    options = "--delete-older-than 7d"; # 删除 7 天以前的所有旧版本
  };

  # 限制 boot 启动菜单中最多只保留最近的 5 个版本
  boot.loader.systemd-boot.configurationLimit = 5;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_SG.UTF-8";
    LC_IDENTIFICATION = "zh_SG.UTF-8";
    LC_MEASUREMENT = "zh_SG.UTF-8";
    LC_MONETARY = "zh_SG.UTF-8";
    LC_NAME = "zh_SG.UTF-8";
    LC_NUMERIC = "zh_SG.UTF-8";
    LC_PAPER = "zh_SG.UTF-8";
    LC_TELEPHONE = "zh_SG.UTF-8";
    LC_TIME = "zh_SG.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # 显式开启 Polkit 提权服务授权
  security.polkit.enable = true;

  # ---------- 输入法配置 ----------
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        (fcitx5-rime.override { rimeDataPkgs = [ rime-ice ]; })
        fcitx5-gtk
      ];
    };
  };

  # User Account
  users.users."qings" = {
    isNormalUser = true;
    description = "qingshanblue";
    extraGroups = [ "networkmanager" "wheel" "seat" ];
    packages = with pkgs; [];
    shell = pkgs.zsh; # 指定默认 Shell 为 Zsh
  };

  nixpkgs.config.allowUnfree = true;

  # ---------- 系统软件包 ----------
  environment.systemPackages = with pkgs; [
    nemo
    google-chrome
    walker
    elephant
    kitty
    vscode
    git
    neovim
    qt6Packages.fcitx5-configtool
    # xarchiver
    waybar
    swaynotificationcenter
    hyprpolkitagent # 提权 Agent
    hyprpaper
    fastfetch
    telegram-desktop
    # wechat
    # qq
    steam-run
    bottles
    # pince
    fd
    go-musicfox
    olympus
    ouch
    kdePackages.ark
    kdePackages.kate
    hyprshot
    # gui-for-singbox
    aria2
    mission-center
    glib # for gsettings
    xdg-user-dirs # for xdg-user-dirs-update
  ];

  services.cron = {
    enable = true;
    systemCronJobs = [
      "00 01 * * * root /run/current-system/sw/bin/shutdown -h now"
    ];
  };

  # ---------- Steam 官方推荐开启方式 ----------
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # (可选) 开启远程畅玩防火墙端口
    dedicatedServer.openFirewall = true; # (可选) 开启专服防火墙端口
  };

  # ---------- 开启 Flatpak 支持与 Portal 补全 ----------
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # ---------- Zsh 配置 ----------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # ---------- Starship 配置 ----------
  programs.starship = {
    enable = true;
  };

  # Hyprland 配置
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true; # 启用 uwsm 生成会话
  };

  # sunshine
  services.sunshine.enable = true;

  # Aria2c
  # services.aria2 = {
    # enable = true;
    # rpcSecretFile = pkgs.writeText "aria2-secret" "#8fb2c9";
    # settings = {
    #   enable-rpc = true;
    #   rpc-listen-all = false;
    #   rpc-allow-origin-all = true;
    #   dir = "/home/qings/Downloads";
    #   max-concurrent-downloads = 5;
    #   max-connection-per-server = 16;
    #   continue = true;
    # };
    # openPorts = false;
  # };

  # direnv
  programs.direnv.enable = true;

  # ---------- nix-ld 配置 ----------
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Webview / Tauri 依赖库
      webkitgtk_4_1
      libsoup_3

      # GTK 与基础图形库
      glib
      gtk3
      cairo
      pango
      gdk-pixbuf
      atk

      # 系统与网络服务
      dbus
      openssl
      nss
      nspr

      # 显示与 Wayland/X11
      libxkbcommon
      wayland
      libx11
      libxcursor
      libxrandr
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxi
      libxrender
      libxtst
      libxcb

      # 硬件加速与音频
      alsa-lib
      mesa
    ];
  };

  # 字体配置
  fonts.packages = with pkgs; [
    maple-mono.NF-CN-unhinted
  ];

  # ---------- SDDM (Wayland 模式) 配置 ----------
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # 使用 Wayland 渲染登录界面
  };

  # 图形与驱动
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
  };

  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };

  # ---------- 合盖行为设置 ----------
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "ignore";               # 1. 电池供电时
      HandleLidSwitchExternalPower = "ignore";  # 2. 插电源时
      HandleLidSwitchDocked = "ignore";         # 3. 连接扩展坞/外接显示器时
    };
  };

  # ---------- 防火墙配置 ----------
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 20122 ];
    allowedUDPPorts = [ 20122 ];
  };

  # ---------- 镜像源配置 ----------
  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
    ];
  # ---------- 版本标识 -----------
  system.stateVersion = "26.05";
}
