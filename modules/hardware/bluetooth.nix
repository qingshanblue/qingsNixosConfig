# 蓝牙：控制器软硬件支持与开机自启。

{ config, pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}
