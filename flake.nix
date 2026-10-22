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
        # 这里导入之前我们使用的 configuration.nix，
        # 这样旧的配置文件仍然能生效
        ./configuration.nix
      ];
    };
  };
}