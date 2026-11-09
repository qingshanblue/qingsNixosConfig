# 引导与内核：GRUB 主题、tuxedo-drivers 内核补丁、休眠 resume 参数。

{ config, pkgs, ... }:

{
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

  # tuxedo-drivers 4.20.1 的 Makefile 把 $(MAKEFLAGS) 展开进 recipe；新版 nixpkgs 的
  # kernelModuleMakeFlags 含 cmd_sign=...$(space)$@（MAKEFLAGS 中转义成 $$(space)），
  # bash 会当 $$(PID)+( 而报语法错误。让子 make 从环境继承变量即可（保留 kmodigest 签名，
  # 签名证书是 nixpkgs 组装 linux-modules 必需的）。--replace-fail 保证上游改了就报错。
  # TODO: nixpkgs 修复 cmd_sign/MAKEFLAGS 互操作后删掉这段。
  boot.kernelPackages = pkgs.linuxPackages.extend (final: prev: {
    tuxedo-drivers = prev.tuxedo-drivers.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace Makefile --replace-fail ' $(MAKEFLAGS)' ""
      '';
    });
  });

  boot.kernelParams = [ "resume=UUID=32a6a3c5-1ece-42cf-b802-9cb043a56e21" ];
  boot.kernelModules = [ "usbmon" ];
}
