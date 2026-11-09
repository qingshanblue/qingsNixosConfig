# 嵌入式、电子工程开发环境、EDA 设计软件及配套硬件调试 udev 规则。

{ config, pkgs, ... }:

let
  wrappers = import ../../../lib/wrappers.nix { inherit pkgs; };
  inherit (wrappers) mkScaled;
in
{
  # ---------- 抓包与硬件接口分析 ----------
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
    dumpcap.enable = true;
    usbmon.enable = true;
  };

  # ---------- 硬件调试器 udev 规则与权限 ----------
  services.udev = {
    packages = [ pkgs.libsigrok pkgs.openocd ];
    extraRules = ''
      # DAPLink / CMSIS-DAP 调试器免 root 访问
      SUBSYSTEM=="usb", ATTR{idVendor}=="faed", ATTR{idProduct}=="4870", MODE="0666", TAG+="uaccess"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="faed", ATTRS{idProduct}=="4870", MODE="0666", TAG+="uaccess"
      # Wireshark usbmon 权限
      SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
    '';
  };

  # ---------- 工程与 EDA 软件包 ----------
  environment.systemPackages = with pkgs; [
    # 固件烧录与芯片调试
    openocd
    stm32flash
    gcc-arm-embedded

    # KiCad 10
    # KiCad 10 的“选择工程模板”对话框用 wxWebView(WebKitGTK) 渲染模板预览。
    # WebKit 的 DMA-BUF 渲染器会为该 toplevel 的 wl_surface 启用 linux-drm-syncobj
    # 显式同步，而 GTK3 随后用共享内存 wl_buffer 提交同一 surface 却没带 acquire
    # timeline；Hyprland 按协议报 no_acquire_point 并断开客户端，GDK3 收到断连后
    # 静默 _exit(1) —— 表现为“点任意模板后 KiCad 瞬间消失”（无 stderr、无 core）。
    # 规避：让 webview 退回软件渲染，预览仍然正常显示。
    # 待 WebKitGTK / GTK3 / NVIDIA egl-wayland 上游修复后，删除本 override、
    # 直接写回 `kicad` 即可。
    (kicad.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
      postInstall = (old.postInstall or "") + ''
        for prog in kicad pcbnew eeschema gerbview pcb_calculator pl_editor; do
          wrapProgram "$out/bin/$prog" --set WEBKIT_DISABLE_DMABUF_RENDERER 1
        done
      '';
    }))

    # STM32CubeMX
    # STM32CubeMX 是 Swing/AWT（XWayland）。Java2D 的 sun.java2d.uiScale 只支持整数，
    # 实测 1.6/1.5 都被截断成 1。只能在 1（太小）和 2（比 1.6 大 25%，但清晰）之间选 2；
    # 只作用于 CubeMX（以前是全局 _JAVA_OPTIONS，会顺带影响所有 JVM）。
    (mkScaled "stm32cubemx-scaled" stm32cubemx "stm32cubemx"
      ''--set _JAVA_OPTIONS "-Dsun.java2d.uiScale=2"'')

    # 电路仿真与 3D 建模
    ngspice
    simulide
    freecad
    openscad

    # 逻辑分析仪与示波器
    pulseview
    sigrok-cli
    sigrok-firmware-fx2lafw
  ];
}
