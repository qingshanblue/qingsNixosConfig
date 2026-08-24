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
    extraGroups = [ "networkmanager" "wheel" "seat" "tty" "input" "podman" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqmCl4hD4e1vYIa7yCE30jpCSutMYJgEF6fiw8s26l6 qingshanblue@gmail.com"
    ];
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
    # # Development
    git
    android-tools
    nodejs
    bun
    llvm
    cmake
    python3
    pixi
    rustc
    cargo
    # # System
    glib
    xdg-user-dirs
    busybox
    neovim
    kitty
    nemo
    elephant
    walker
    waybar
    swaynotificationcenter
    kdePackages.ark
    hyprpolkitagent
    hyprpaper
    hyprshot
    fastfetch
    qt6Packages.fcitx5-configtool
    mission-center
    adwaita-icon-theme
    papirus-icon-theme
    better-control
    pavucontrol
    blueman
    bluez-tools
    google-chrome
    vscode
    motrix-next
    celluloid
    swayimg
    steam-run
    appimage-run
    ouch
    fd
    # # User
    scrcpy
    go-musicfox
    telegram-desktop
    wpsoffice-cn
    podman-desktop
    gparted
    # gui-for-singbox
    # # Games
    bottles
    olympus
    hmcl
    osu-lazer
    # # Agents
    cc-switch
    claude-code
    codex
    # hermes
    opencode
    # DeepSeek Harness
    pi-coding-agent
    goose-cli
    # # close
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

  # ---------- Shell 与提示符 ----------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
  programs.starship.enable = true;

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

  # ---------- Podman 容器虚拟化 ----------
  virtualisation.podman = {
    enable = true;
    # 创建 `docker` 命令别名，这样原本基于 docker 的脚本和工具可以直接使用
    dockerCompat = true;
    # 启用默认网络的 DNS 解析（容器之间可以通过名称互相访问）
    defaultNetwork.settings.dns_enabled = true;
  };

  # ---------- 桌面环境 ----------
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  # programs.niri.enable = true;

  # ---------- Sunshine ----------
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = false;
    openFirewall = true;
    settings.port = 47989;
  };

  # ---------- Steam ----------
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
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

  # llama cpp
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp.override {
      cudaSupport = true;
    };
    settings = {
      host = "127.0.0.1";
      port = 8080;
      # Hunyuan-MT-7B Q4_K_M，手动下载到 StateDirectory（沙箱内可读）
      model = "/var/lib/llama-cpp/hunyuan-mt-7b-q4_k_m.gguf";
      # 不手动设 n-gpu-layers，让 llama-server 按空闲显存自动分层
      ctx-size = 8192;
      parallel = 1; # 上下文平行量，实际单会话上下文 = ctx-size / parallel
      temp = 0.7;
    };
    openFirewall = false;
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

  # ---------- SSH 服务 ----------
  services.openssh = {
    enable = true;
    ports = [ 2222 ]; # 默认端口为 22，如果想改端口（如 2222），修改这里
    settings = {
      PasswordAuthentication = false; # 禁用密码登录，更安全
      PermitRootLogin = "no";         # 禁止 root 用户直接登录
      PubkeyAuthentication = true;    # 允许使用密钥认证
    };
    # 如果你想允许 X11 转发或端口转发，可以在这里开启（默认关闭是安全的）
    # settings.X11Forwarding = true;
    # settings.AllowTcpForwarding = "yes";
  };

  programs.proxychains = {
    enable = true;
    proxies = {
      localProxy = {
        type = "socks5";
        host = "localhost";
        port = "20122";
      };
    };
  };

  # ---------- 防火墙 ----------
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 2222 20122 ];
    allowedUDPPorts = [ 20122 ];
  };

  nixpkgs.config.allowUnfree = true;

  # ---------- Nix 设置与镜像源 ----------
  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    # 显式声明信任公钥
    trusted-public-keys = [
      # 
    ];
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true; # 写入时自动去重硬链接
  };

  # ---------- 版本标识 -----------
  system.stateVersion = "26.05";
}