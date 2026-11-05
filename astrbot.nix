{ ... }:

# AstrBot（聊天机器人框架），由 Podman 以 systemd 服务方式托管。
#
# 说明：
# - 与 Label Studio 一致，使用 rootful Podman（oci-containers 默认以 root 运行）。
# - AstrBot 官方 Docker 命令使用 `-v $PWD/data:/AstrBot/data`，容器内进程需要对
#   挂载目录有写权限。下面将宿主机目录的所有者设为与容器内运行用户一致。
#   AstrBot 镜像内通常以 UID 1000 运行（与多数非 root 镜像习惯一致），
#   若后续仍出现 Permission denied，可尝试改为 1001:1001。
# - 端口：6185 为 WebUI，6199 为 OneBot v11 反向 WebSocket 默认端口。
# - 时区：挂载宿主机 /etc/localtime 与 /etc/timezone，避免容器内时间错乱。

{
  # 数据目录：配置、数据库、插件等都在这里
  systemd.tmpfiles.rules = [
    "d /var/lib/astrbot 0755 1000 1000 -"
  ];

  virtualisation.oci-containers = {
    backend = "podman";

    containers.astrbot = {
      # 建议同样按 digest 固定，升级时更新 digest。
      # 获取最新 digest 的方式与 Label Studio 类似，将 repository 替换为 soulter/astrbot 即可。
      image = "docker.io/soulter/astrbot:latest"; # 可替换为 @sha256:... 以固定版本
      ports = [
        "127.0.0.1:6185:6185"
        "127.0.0.1:6199:6199"
      ];
      volumes = [
        "/var/lib/astrbot:/AstrBot/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        TZ = "Asia/Taipei";   # 可选：容器内需要读取 TZ 的程序（如 Python 的 datetime）会用到
      };
      autoStart = true;
    };
  };
}