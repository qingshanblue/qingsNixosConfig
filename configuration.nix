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
      useOSProber = true; # 如果单系统不需要探测，可改为 false 加快启动
      theme = pkgs.catppuccin-grub.override {
        flavor = "mocha";
      };
    };
    efi.canTouchEfiVariables = true;
  };

  boot.kernelPackages = pkgs.linuxPackages;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Singapore";

  # ---------- 国际化与 Locale ----------
  i18n.defaultLocale = "zh_CN.UTF-8";
  # 显式声明支持的 locales，防止 zh_SG.UTF-8 未生成导致回退
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "zh_CN.UTF-8/UTF-8"
    "zh_SG.UTF-8/UTF-8"
  ];

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

  # ---------- 字体配置 ----------
  fonts.packages = with pkgs; [
    maple-mono.NF-CN-unhinted
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  # 固定字体回退顺序，防止中文或 emoji 显示成豆腐
  fonts.fontconfig.defaultFonts = {
    monospace = [ "MapleMono NF CN" "Noto Sans Mono CJK SC" ];
    sansSerif = [ "Noto Sans CJK SC" "Noto Sans" ];
    serif    = [ "Noto Serif CJK SC" "Noto Serif" ];
    emoji    = [ "Noto Color Emoji" ];
  };

  # ---------- 用户账户 ----------
  users.users."qings" = {
    isNormalUser = true;
    description = "qingshanblue";
    extraGroups = [ "networkmanager" "wheel" "seat" "tty" "input" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  # ---------- Nix 设置与镜像源 ----------
  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    # 必须显式声明信任公钥，否则非官方镜像可能被静默忽略
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHbD9b2j5Tum1L0A8qhcJ9wUpN4Lo2RnBS4a4s4O0="
    ];
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true; # 写入时自动去重硬链接
  };

  # ---------- 垃圾回收与存储优化 ----------
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d"; # 保留 14 天以便回滚
  };
  nix.optimise.automatic = true; # 定期运行 nix-store --optimise

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
    hyprpolkitagent
    hyprpaper
    fastfetch
    telegram-desktop
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
    glib
    xdg-user-dirs
    zeroclaw
    wpsoffice-cn
    motrix-next
    appimage-run
    celluloid
    swayimg
    android-tools
    scrcpy
    hmcl
    osu-lazer
    busybox
    papirus-icon-theme
    blueman
    bluez-tools
  ];

  # ---------- Nix-ld (用于运行预编译二进制) ----------
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc.lib
      glib
      libGL
      libxkbcommon
      fontconfig
      freetype
      wayland
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

  # ---------- 定时任务 ----------
  # 改为提前 3 分钟警告关机，避免数据丢失
  services.cron = {
    enable = true;
    systemCronJobs = [
      "00 01 * * * root /run/current-system/sw/bin/shutdown -h +3 \"System auto shutdown in 3 minutes...\""
    ];
  };

  # ---------- Steam ----------
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # ---------- Flatpak 与 Portal ----------
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # ---------- Shell 与提示符 ----------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
  programs.starship.enable = true;

  # ---------- 桌面环境 ----------
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  programs.niri.enable = true;

  # ---------- Sunshine ----------
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = false;
    openFirewall = true;
    settings.port = 47989;
  };

  # ---------- 开发工具 ----------
  programs.direnv.enable = true;  # NixOS 模块默认已自动集成 nix-direnv

  # ---------- 登录管理器 ----------
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # ---------- 系统服务 ----------
  security.polkit.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # ---------- 图形与 NVIDIA 驱动 ----------
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # Steam 32位游戏必需

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;                  # Ampere 支持，保留
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement = {
      enable = true;              # 保存/恢复 VRAM 状态，修复休眠唤醒黑屏
      # finegrained = true;       # dGPU 直连内屏时无法启用，注释掉
    };
  };

  # ---------- 网络与蓝牙 ----------
  # 蓝牙
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # 开机自动开启蓝牙
  };

  # 设备驱动
  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };

  # ---------- 环境变量 ----------
  environment.sessionVariables = {
    NVD_BACKEND = "direct";
    GBM_BACKEND = "nvidia-drm"; # dGPU 直连内屏才保留，PRIME 模式请删除
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # 让 Electron/Qt 优先走 Wayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";

    # Wayland 下 fcitx5 走 text-input 协议，不建议手动设 *_IM_MODULE
    # 如果某个 XWayland 应用收不到输入，再单独在应用启动参数中指定
  };

  # ---------- 合盖行为 ----------
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
  };

  # ---------- 防火墙 ----------
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 20122 ];
    allowedUDPPorts = [ 20122 ];
  };

  # ---------- 版本标识 -----------
  system.stateVersion = "26.05";
}