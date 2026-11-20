# flatpak 的 NVIDIA GL 扩展必须与宿主驱动版本精确匹配：flatpak 读 /sys/module/nvidia/version
# 拼出 org.freedesktop.Platform.GL.nvidia-<版本，点换成横线>，匹配不到就退回 Mesa 软渲染
# （应用照样能跑，但没有 GPU 加速）。
#
# 这里把扩展 ID 直接由 hardware.nvidia.package.version 推导，驱动与扩展永远同源：
# nix flake update 换了驱动后，下次开机自动补装对应扩展；flathub 还没发布时只告警，不阻塞启动。
# 已装（ID 相同即版本相同）时直接退出，不联网、不下载。
#
# 32 位 flatpak 应用（Wine/Steam）还需要 org.freedesktop.Platform.GL32.nvidia-<同版本>，用得上时再加。

{ config, lib, pkgs, ... }:

let
  glId = "org.freedesktop.Platform.GL.nvidia-"
    + lib.replaceStrings [ "." ] [ "-" ] config.hardware.nvidia.package.version;
in
{
  systemd.services.flatpak-nvidia-gl = {
    description = "Keep flatpak's NVIDIA GL extension in sync with the host driver";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "flatpak-nvidia-gl" ''
        flatpak=${pkgs.flatpak}/bin/flatpak
        if $flatpak info "${glId}" >/dev/null 2>&1; then
          exit 0
        fi
        $flatpak update --appstream flathub >/dev/null 2>&1 || true
        $flatpak install -y --noninteractive flathub "${glId}" \
          || echo "flatpak: flathub 尚无 ${glId}，flatpak 应用将退回 Mesa 软渲染" >&2
      '';
    };
  };
}