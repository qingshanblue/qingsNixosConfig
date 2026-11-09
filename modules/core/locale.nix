# 时区、NTP、语言环境、输入法、字体与 /usr/share/fonts 兼容层。

{ config, pkgs, ... }:

{
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
    dejavu_fonts
    liberation_ttf
    wqy_microhei
    wqy_zenhei
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "MapleMono NF CN" "Noto Sans Mono CJK SC" ];
    sansSerif = [ "Noto Sans CJK SC" "Noto Sans" ];
    serif    = [ "Noto Serif CJK SC" "Noto Serif" ];
    emoji    = [ "Noto Color Emoji" ];
  };

  # ---------- /usr/share/fonts 兼容层 ----------
  systemd.tmpfiles.rules = [
    # --- DejaVu（Unity Linux fallback 硬编码路径，本条直接修复 Mortuus）---
    "L+ /usr/share/fonts/truetype/dejavu - - - - ${pkgs.dejavu_fonts}/share/fonts/truetype"

    # --- Noto CJK（Debian/Arch 的 noto 布局）---
    "L+ /usr/share/fonts/opentype/noto - - - - ${pkgs.noto-fonts-cjk-sans}/share/fonts/opentype/noto-cjk"

    # --- WenQuanYi（老程序 / Wine 常见探测点）---
    "L+ /usr/share/fonts/truetype/wqy - - - - ${pkgs.wqy_microhei}/share/fonts/truetype"

    # --- 其余常见目录，覆盖按目录扫描的程序 ---
    "L+ /usr/share/fonts/truetype/noto - - - - ${pkgs.noto-fonts}/share/fonts/truetype"
    "L+ /usr/share/fonts/truetype/liberation - - - - ${pkgs.liberation_ttf}/share/fonts/truetype"
  ];
}
