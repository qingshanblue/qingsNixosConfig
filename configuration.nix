{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ---------- Bootloader ----------
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      # 主题设置
      theme = pkgs.catppuccin-grub.override {
        flavor = "mocha";           # 深色主题风格 (mocha / macchiato / frappe)
      };
    };
    efi.canTouchEfiVariables = true;
  };

  # Use kernel.
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
    dates = "daily";            # 自动清理
    options = "--delete-older-than 3d"; # 删除 n 天以前的所有旧版本
  };

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
    extraGroups = [ "networkmanager" "wheel" "seat" "tty" "input" ];
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
    fd
    go-musicfox
    olympus
    ouch
    kdePackages.ark
    kdePackages.kate
    hyprshot
    mission-center
    glib # for gsettings
    xdg-user-dirs # for xdg-user-dirs-update
    zeroclaw
    wpsoffice-cn
    motrix-next
    appimage-run
    celluloid
    swayimg
    android-tools
    scrcpy
    rPackages.lcda
    # pi-coding-agent
    # opencode
  # FHS Env
  ];

  # nix ld
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # 基础 C/C++ 运行时
      zlib
      zstd
      stdenv.cc.cc.lib
      glib

      # 图形与渲染
      libGL
      libxkbcommon
      fontconfig
      freetype
      wayland

      # X11 与 Qt 基础库（已更新为扁平化包名）
      libxcb-cursor
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-wm
      libx11
      libxext
      libxi
      libxrender
      libxrandr
      libxcursor
      libxcomposite
      libxdamage
      libxfixes
      libxcb
      dbus
    ];
  };

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
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = false;
    openFirewall = true;
    settings.port = 47989;
  };

  # direnv
  programs.direnv.enable = true;

  # 字体配置
  fonts.packages = with pkgs; [
    maple-mono.NF-CN-unhinted
  ];

  # ---------- SDDM (Wayland 模式) 配置 ----------
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # 使用 Wayland 渲染登录界面
  };

  # 开启 GVfs 支持（Nemo 依赖它来实现回收站、挂载、网络共享等功能）
  services.gvfs.enable = true;
  # 在系统软件包中加入 udisks2 和 gvfs 工具链（确保文件删除操作具备文件系统权限）
  services.udisks2.enable = true;

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