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

  boot.kernelParams = [
    "resume=UUID=32a6a3c5-1ece-42cf-b802-9cb043a56e21"
    # 强制启用 NVIDIA DRM KMS 与 Framebuffer，避免早期驱动切换时工作队列竞争/冻结
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    # 防止控制台在驱动移交时延迟绑定导致工作队列死锁
    "fbcon=nodefer"
  ];
  boot.kernelModules = [ "usbmon" ];
}
