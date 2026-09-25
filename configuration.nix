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
      theme = pkgs.catppuccin-grub.override {
        flavor = "mocha";
      };
    };
    efi.canTouchEfiVariables = true;
  };

  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [ "resume=UUID=32a6a3c5-1ece-42cf-b802-9cb043a56e21" ];

  # ---------- 内核参数 ----------
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Taipei";
  networking.timeServers = [                                                       
    "ntp.aliyun.com"                                                               
    "ntp1.aliyun.com"                                                              
    "ntp2.aliyun.com"                                                              
    "time1.cloud.tencent.com"                                                      
  ];

  # ---------- 国际化与 Locale ----------
  i18n.defaultLocale = "zh_TW.UTF-8";
  i18n.supportedLocales = [
    "zh_TW.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_TW.UTF-8";
    LC_IDENTIFICATION = "zh_TW.UTF-8";
    LC_MEASUREMENT = "zh_TW.UTF-8";
    LC_MONETARY = "zh_TW.UTF-8";
    LC_NAME = "zh_TW.UTF-8";
    LC_NUMERIC = "zh_TW.UTF-8";
    LC_PAPER = "zh_TW.UTF-8";
    LC_TELEPHONE = "zh_TW.UTF-8";
    LC_TIME = "zh_TW.UTF-8";
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
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };

  # ---------- 系统软件包 ----------
  environment.systemPackages = with pkgs; [
    # Waydroid ARM 转译层安装工具
    (stdenv.mkDerivation {
      pname = "waydroid-script";
      version = "2026-01-05";
      src = fetchzip {
        url = "https://github.com/casualsnek/waydroid_script/archive/d5289cfd8929e86e7f0dc89ecadcef8b66930eec.tar.gz";
        sha256 = "sha256-zSHZlhHJHWZRE3I5pYWhD4o8aNpa8rTiEtl2qJTuRjw=";
      };
      nativeBuildInputs = [ makeWrapper ];
      installPhase = ''
        mkdir -p $out/share/waydroid-script $out/bin
        cp -r . $out/share/waydroid-script/
        makeWrapper ${lib.getExe (python3.withPackages (p: with p; [ requests tqdm inquirerpy ]))} \
          $out/bin/waydroid-script \
          --add-flags "$out/share/waydroid-script/main.py"
      '';
    })
    
    # Development
    git yq android-tools nodejs typescript bun typescript-language-server
    clang bintools lldb clang-tools cmake gnumake
    python3 pixi uv
    rustc cargo rust-analyzer clippy rustfmt
    go gopls delve golangci-lint
    
    # System & Desktop
    glib wget xdg-user-dirs busybox neovim kitty nemo
    elephant walker waybar swaynotificationcenter
    kdePackages.ark hyprpolkitagent hyprpaper hyprshot hyprlock
    fastfetch qt6Packages.fcitx5-configtool mission-center
    adwaita-icon-theme papirus-icon-theme 
    # better-control parses pactl output by English field names (Name/Description);
    # under zh locale pactl emits Chinese keys, so the volume page shows no devices.
    # Force C.UTF-8 inside this app only.
    (better-control.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/better-control --set LC_ALL C.UTF-8
      '';
    })) 
    pavucontrol blueman bluez-tools google-chrome firefox
    vscode.fhs motrix-next celluloid swayimg steam-run appimage-run
    ouch fd iptables
    
    # User Apps
    gui-for-singbox #YesPlayMusic
    scrcpy go-musicfox 
    qq wechat telegram-desktop
    wpsoffice-cn libreoffice podman-desktop gparted
    obsidian zotero kdePackages.okular
    
    # Games
    protonup-rs bottles olympus hmcl osu-lazer
    
    # Agents
    cc-switch claude-code codex pi-coding-agent
  ];

  # ---------- Nix-ld (用于运行预编译二进制) ----------
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib zstd stdenv.cc.cc.lib glib libGL libxkbcommon fontconfig libxshmfence 
      freetype wayland libxcb-cursor libxcb-image libxcb-keysyms
      libxcb-render-util libxcb-wm libx11 libxext libxi libxrender fuse2
      libxrandr libxcursor libxcomposite libxdamage libxfixes libxcb dbus 
    ];
  };

  # ---------- 定时任务 ----------
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
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # ---------- Podman 容器虚拟化 ----------
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # ---------- 桌面环境 ----------
  # services.desktopManager.plasma6.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # ---------- Sunshine  ----------
  services.sunshine = {
    enable = true;
    autoStart = false;
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
  programs.direnv.enable = true;

  # ---------- 登录管理器 ----------
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = "qings";
    };
  };

  # ---------- 系统服务 ----------
  security.polkit.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;

  # ---------- 音频 ----------
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ==============================================================
  # ---------- 图形与 NVIDIA 驱动 (最小化基准配置) ----------
  # ==============================================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;  # 休眠唤醒需要
  };
  # ==============================================================

  # ---------- Waydroid ----------
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  # ---------- 网络与蓝牙 ----------
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };

  # ==============================================================
  # ---------- 环境变量 (清理为最小化) ----------
  # ==============================================================
  # 移除了所有 NVD_BACKEND、GBM_BACKEND 和 WLR_DRM_NO_ATOMIC 等覆盖。
  # 仅保留让 Electron 应用在 Wayland 下正常运行的基础变量。
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
  environment.variables.EDITOR = "nvim";
  # ==============================================================

  # ---------- 合盖行为 ----------
  services.logind.settings = {
    Login = {
      IdleAction = "lock";
      IdleActionUSec = "10min";
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
  };

  # ---------- SSH 服务 ----------
  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
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

  # ---------- Tailscale 组网 ----------
  # 手机端装 Tailscale App 登同一账号，Moonlight 连本机 100.x.x.x
  services.tailscale = {
    enable = true;
    openFirewall = true;  # 放行 UDP 41641，提高打洞直连成功率
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
      "https://mirrors.cernet.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHbD9b2j5Tum1L0A8qhcJ9wUpN4Lo2RnBS4a4s4O0="
    ];
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # ---------- 版本标识 -----------
  system.stateVersion = "26.05";
}
