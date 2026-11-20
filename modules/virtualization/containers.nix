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

  # QQ 官方机器人（botpy）用 aiohttp.ClientSession() 发请求，没传 trust_env，
  # 于是一概忽略容器的 http_proxy/https_proxy 直连；bridge 网络下直连 TCP 出不去
  # （sing-box 的 nft 规则会在 prerouting 把它截走），表现为 TimeoutError。
  #
  # 这里放一个 sitecustomize.py，把 aiohttp 默认的 trust_env 打开（显式传
  # trust_env=False 的调用仍被尊重），再用 PYTHONPATH 让容器内所有 Python 进程
  # 启动时自动加载。no_proxy 里的 localhost/127.0.0.1 保证容器自访问不走代理。
  environment.etc."astrbot/sitecustomize.py".text = ''
    """让 aiohttp 默认遵守 *_proxy 环境变量（botpy 等未传 trust_env 的调用）。"""

    try:
        import aiohttp
    except Exception:  # aiohttp 尚未安装（镜像构建阶段）时保持沉默
        aiohttp = None

    if aiohttp is not None:
        _orig_init = aiohttp.ClientSession.__init__

        def _init(self, *args, **kwargs):
            kwargs.setdefault("trust_env", True)
            _orig_init(self, *args, **kwargs)

        aiohttp.ClientSession.__init__ = _init
  '';

  virtualisation.oci-containers = {
    backend = "podman";

    containers.astrbot = {
      image = "docker.io/soulter/astrbot:latest";
      ports = [
        "6185:6185"
        "6199:6199"
      ];
      volumes = [
        "/var/lib/astrbot:/AstrBot/data"
        "/etc/localtime:/etc/localtime:ro"
        "/etc/astrbot/sitecustomize.py:/opt/sitecustomize.py:ro"
      ];
      environment = {
        TZ = "Asia/Taipei";
        PYTHONPATH = "/opt";
      };
      autoStart = true;
    };
  };

  # LAN 访问：放行 AstrBot WebUI(6185) 与 OneBot v11(6199)
  networking.firewall.allowedTCPPorts = [ 6185 6199 ];
}
