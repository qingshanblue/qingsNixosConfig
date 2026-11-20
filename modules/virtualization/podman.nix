# 容器运行时：Podman（rootful，供 oci-containers 使用与命令行管理）。

{ config, pkgs, ... }:

{
  environment.etc."containers/registries.conf".text = ''
    unqualified-search-registries = ["docker.io"]
  '';

  # 容器默认代理（对所有 podman 容器生效，包括 oci-containers 托管的 astrbot）。
  #
  # podman 的 containers.conf 默认 http_proxy = true：把宿主机的 http_proxy /
  # https_proxy / all_proxy 原样注入容器。宿主机这套值是 127.0.0.1:20122，而容器
  # 走 bridge 网络时 127.0.0.1 是容器自己的 loopback，代理必然连不上。
  # 所以先关掉注入，再显式指向宿主机侧的容器网桥地址：
  # host.containers.internal 由 podman 自动写入容器 /etc/hosts（rootful = 10.88.0.1，
  # rootless = 169.254.1.2），比写死网段更抗网络重建。
  #
  # ws_proxy / wss_proxy 必须显式给出：aiohttp 是按 URL scheme 取代理的
  # （helpers.proxies_from_env 只保留 http/https/ws/wss 四个键，
  # get_env_proxy_for_url 里是 proxies_in_env[url.scheme]），而 all_proxy 会被
  # 直接丢掉。于是 botpy 连 wss://api.sgroup.qq.com/websocket 时，只有
  # http_proxy/https_proxy 的话会 LookupError -> 静默回落成直连；bridge 网络下
  # 直连被 sing-box 的 nft prerouting 截走，表现为 60s ConnectionTimeoutError，
  # QQ 侧则是「该机器人未连接灵魂」。
  environment.etc."containers/containers.conf.d/10-proxy.conf".text = ''
    [containers]
    http_proxy = false
    env = [
      "http_proxy=http://host.containers.internal:20122",
      "https_proxy=http://host.containers.internal:20122",
      "all_proxy=socks5://host.containers.internal:20122",
      "ws_proxy=http://host.containers.internal:20122",
      "wss_proxy=http://host.containers.internal:20122",
      "no_proxy=localhost,127.0.0.1,::1,host.containers.internal",
      "HTTP_PROXY=http://host.containers.internal:20122",
      "HTTPS_PROXY=http://host.containers.internal:20122",
      "ALL_PROXY=socks5://host.containers.internal:20122",
      "WS_PROXY=http://host.containers.internal:20122",
      "WSS_PROXY=http://host.containers.internal:20122",
      "NO_PROXY=localhost,127.0.0.1,::1,host.containers.internal",
    ]
  '';

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
