# 显卡与图形：NVIDIA 官方驱动、GSP 固件、电源管理，以及 VA-API over NVDEC 桥接。
#
# VA-API 三件套（缺一不可）：
#   1. nvidia-vaapi-driver（下面 extraPackages）+ nvidia-drm.modeset=1
#   2. 会话环境变量 LIBVA_DRIVER_NAME=nvidia / NVD_BACKEND=direct（见 users/qings.nix）
#   3. 应用侧开关：Chrome 需要 feature flag（见 users/profiles/desktop-apps.nix）
# 2026-11-14 实测：ffmpeg 走 vaapi 解 HEVC Main 90 帧 0 错误，direct backend 与 595 驱动兼容。

{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver   # 通过 NVDEC 提供 VA-API，浏览器硬解 HEVC 靠它
    ];
  };

  # vainfo：验证驱动层（VAProfileHEVCMain / Main10 等）
  environment.systemPackages = [ pkgs.libva-utils ];

  nixpkgs.config.nvidia.acceptLicense = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;      # nvidia-vaapi-driver 需要 nvidia-drm.modeset=1，你已经开了
    nvidiaSettings = true;
    powerManagement.enable = true;
    gsp.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
