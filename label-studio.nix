{ ... }:

# Label Studio（数据标注平台），由 Podman 以 systemd 服务方式托管。
#
# 说明：
# - 使用 rootful Podman（oci-containers 默认以 root 的 systemd 服务运行）。
#   容器内进程以 UID 1001 运行，宿主机目录直接 chown 给 1001，无需 podman unshare。
# - 镜像按 digest 固定，保证可复现；升级时更新 digest 并 nixos-rebuild switch。
#   取最新 digest：
#     curl -s "https://hub.docker.com/v2/repositories/heartexlabs/label-studio/tags/latest" \
#       | python3 -c 'import sys,json;d=json.load(sys.stdin);print([i["digest"] for i in d["images"] if i["architecture"]=="amd64"])'
# - 端口只绑定 127.0.0.1，访问地址 http://localhost:8080

{
  # 数据目录：SQLite 数据库、上传文件、导出文件都在这里
  systemd.tmpfiles.rules = [
    "d /var/lib/label-studio 0755 1001 1001 -"
  ];

  # 服务以 root 运行、不继承用户会话的代理变量；直连 registry-1.docker.io 会 TLS 超时。
  # 这里显式指定本机代理（与 configuration.nix 中 proxychains 使用的端口一致）。
  systemd.services.podman-label-studio.environment = {
    http_proxy = "http://127.0.0.1:20122";
    https_proxy = "http://127.0.0.1:20122";
    no_proxy = "localhost,127.0.0.1,::1";
  };

  virtualisation.oci-containers = {
    backend = "podman";

    containers.label-studio = {
      image = "docker.io/heartexlabs/label-studio@sha256:844f82c5b08de3f77a57c66f480e0036d3c76c6eff53699e8d47686613faa922";
      ports = [ "127.0.0.1:8080:8080" ];
      volumes = [ "/var/lib/label-studio:/label-studio/data" ];
      autoStart = true;
    };
  };
}
