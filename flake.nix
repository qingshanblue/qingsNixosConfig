{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS 官方软件源，这里使用镜像
    nixpkgs.url = "tarball+https://mirrors.cernet.edu.cn/nix-channels/nixos-unstable/nixexprs.tar.xz";
    # llm-agents
    llm-agents.url = "github:Qumulo/llm-agents";
  };

  outputs = { self, nixpkgs, llm-agents, ... }@inputs: {
    # TODO 请将下面的 my-nixos 替换成你的 hostname
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./hardware-configuration.nix

        # 按主题拆分的模块，具体内容见 modules/ 目录
        ./modules/boot.nix
        ./modules/nix.nix
        ./modules/users.nix
        ./modules/locale.nix
        ./modules/network.nix
        ./modules/hardware.nix
        ./modules/desktop.nix
        ./modules/services.nix
        ./modules/programs.nix
        ./modules/containers.nix
        ./modules/packages.nix
        ./modules/apps.nix

        # 版本标识 stateVersion（勿随意修改）
        { system.stateVersion = "26.05"; }
      ];
    };
  };
}