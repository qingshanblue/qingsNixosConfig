# 开发环境软件包与工具链（语言运行时、构建工具、调试器、兼容运行层、AI Agent）。

{ config, pkgs, ... }:

{
  # ---------- Nix-ld (运行预编译动态链接 ELF 二进制) ----------
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib zstd stdenv.cc.cc.lib glib libGL libxkbcommon fontconfig
      libxshmfence freetype wayland libxcb-cursor libxcb-image
      libxcb-keysyms libxcb-render-util libxcb-wm libx11 libxext
      libxi libxrender fuse3 libxrandr libxcursor libxcomposite
      libxdamage libxfixes libxcb dbus webkitgtk_4_1 gtk3
      glib-networking gdk-pixbuf cairo pango libsoup_3
      vulkan-loader
    ];
  };

  # 曾用 environment.variables.LD_LIBRARY_PATH 全局注入 nix-ld 的库目录，但那会让 431 个
  # 目录参与**所有**进程的库搜索，可能覆盖程序自带的库版本（ABI 撞车）。nix-ld 本身走
  # NIX_LD + NIX_LD_LIBRARY_PATH，不需要它；需要它的交互式开发场景改由 zsh 的
  # interactiveShellInit 提供（见 users/qings.nix），作用域只到终端里启动的程序。

  # ---------- AppImage 兼容层 ----------
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: with pkgs; [
        libepoxy
        libgpg-error
      ];
    };
  };

  # ---------- 软件开发工具包 ----------
  environment.systemPackages = with pkgs; [
    # 基础版本控制与多端工具
    git
    github-desktop
    yq
    bubblewrap
    socat
    ripgrep
    termius
    android-tools

    # Node / JS / TS
    nodejs
    typescript
    bun
    typescript-language-server

    # C / C++ 构建体系
    clang
    clang-tools
    lldb
    cmake
    ninja
    gnumake
    bintools

    # Python 生态
    python3
    pixi
    uv

    # Rust 生态
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    # Go 生态
    go
    gopls
    delve
    golangci-lint

    # 编辑器
    vscode.fhs

    # AI Agents
    cc-switch
    codex
    claude-code
    pi-coding-agent
  ];
}
