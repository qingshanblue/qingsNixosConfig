# 托管容器实例：AstrBot（由 Podman 托管的聊天机器人框架）。
#
# 说明：
# - 使用 rootful Podman（oci-containers 默认以 root 运行）。
# - AstrBot 官方 Docker 命令使用 `-v $PWD/data:/AstrBot/data`，容器内进程需要对
#   挂载目录有写权限。下面将宿主机目录的所有者设为与容器内运行用户一致。
#   AstrBot 镜像内通常以 UID 1000 运行（与多数非 root 镜像习惯一致），
#   若后续仍出现 Permission denied，可尝试改为 1001:1001。
# - 端口：6185 为 WebUI，6199 为 OneBot v11 反向 WebSocket 默认端口。
# - 时区：挂载宿主机 /etc/localtime 与 /etc/timezone，避免容器内时间错乱。

{ config, pkgs, ... }:

{
  # 数据目录：配置、数据库、插件等都在这里
  systemd.tmpfiles.rules = [
    "d /var/lib/astrbot 0755 1000 1000 -"
  ];

  virtualisation.oci-containers = {
    backend = "podman";

    containers.astrbot = {
      image = "docker.io/soulter/astrbot:latest";
      ports = [
        "127.0.0.1:6185:6185"
        "127.0.0.1:6199:6199"
      ];
      volumes = [
        "/var/lib/astrbot:/AstrBot/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        TZ = "Asia/Taipei";
      };
      autoStart = true;
    };
  };
}
