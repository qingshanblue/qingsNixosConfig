# 命令行 / 开发 / 工程 / Agent 软件包。

{ config, pkgs, ... }:

let
  # ---------- XWayland 缩放包装器 ----------
  mkScaled = name: pkg: bin: wrapperArgs:
    pkgs.symlinkJoin {
      inherit name;
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = "wrapProgram $out/bin/${bin} ${wrapperArgs}";
    };
in
{
  # 把 mkScaled 暴露给 apps.nix（在 apps.nix 的参数里声明）
  _module.args.mkScaled = mkScaled;

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
    git github-desktop yq android-tools nodejs typescript bun typescript-language-server
    clang clang-tools lldb cmake ninja gnumake bintools
    python3 pixi uv
    rustc cargo rust-analyzer clippy rustfmt
    go gopls delve golangci-lint
    bubblewrap socat ripgrep
    termius

    # Engineering
    openocd stm32flash gcc-arm-embedded
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
    # STM32CubeMX 是 Swing/AWT（XWayland）。Java2D 的 sun.java2d.uiScale 只支持整数，
    # 实测 1.6/1.5 都被截断成 1。只能在 1（太小）和 2（比 1.6 大 25%，但清晰）之间选 2；
    # 只作用于 CubeMX（以前是全局 _JAVA_OPTIONS，会顺带影响所有 JVM）。
    (mkScaled "stm32cubemx-scaled" stm32cubemx "stm32cubemx"
      ''--set _JAVA_OPTIONS "-Dsun.java2d.uiScale=2"'')
    ngspice simulide #bambu-studio
    freecad openscad # build123d 
    pulseview sigrok-cli sigrok-firmware-fx2lafw 

    # Agents
    cc-switch codex claude-code pi-coding-agent
  ];

}
