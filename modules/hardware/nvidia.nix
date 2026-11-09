# 显卡与图形：NVIDIA 官方驱动、GSP 固件、电源管理与 Wayland 支持。

{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  nixpkgs.config.nvidia.acceptLicense = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;                    # Ampere 官方主线，电源管理/挂起恢复修复都在这条线
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;  # 休眠唤醒需要
    gsp.enable = true;              # open 模块必需 GSP 固件；stock 包自带，勿回退到手动 pin
    package = config.boot.kernelPackages.nvidiaPackages.stable;  # 锁定渠道内 = 595.104.02
  };
}
