# Android 模拟器环境：Waydroid 及 waydroid-script ARM 转译辅助工具。

{ config, pkgs, lib, ... }:

{
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

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
  ];
}
