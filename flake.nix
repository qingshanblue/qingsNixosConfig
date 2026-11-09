{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS 官方软件源，这里使用镜像
    nixpkgs.url = "tarball+https://mirrors.cernet.edu.cn/nix-channels/nixos-unstable/nixexprs.tar.xz";
    # llm-agents
    llm-agents.url = "github:Qumulo/llm-agents";
  };

  outputs = { self, nixpkgs, llm-agents, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        # 硬件配置底座
        ./hardware-configuration.nix

        # 聚合配置入口（包含所有子模块）
        ./modules/configuration.nix

        # 版本标识 stateVersion（勿随意修改）
        { system.stateVersion = "26.05"; }
      ];
    };
  };
}
