# 笔记本控制：Tuxedo-rs 驱动支持，以及休眠恢复后重建 Uniwill EC 风扇手动控制。

{ config, pkgs, ... }:

{
  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };

  # ---------- 风扇控制：休眠恢复后重建 Uniwill EC 手动控制 ----------
  # S4 恢复会丢两份状态：tuxedo_io 的 fans_initialized 与 EC 0x0741 手动使能位
  # （uniwill_wmi probe 时写入）。需重载两模块并强制写一次转速，见 tuxedo-rs #180。
  systemd.services.tuxedo-fan-resume = {
    description = "Restore Uniwill EC fan control after sleep";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    wantedBy = [ "suspend.target" "hibernate.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let
        script = pkgs.writeShellScript "tuxedo-fan-resume" ''
          # SIGKILL 直接杀：优雅 stop 会触发 tailord 自身 SIGABRT + coredump，白耗 ~2s
          /run/current-system/sw/bin/systemctl kill -s SIGKILL tailord.service 2>/dev/null || true
          /run/current-system/sw/bin/systemctl stop tailord.service 2>/dev/null || true
          /run/current-system/sw/bin/modprobe -r tuxedo_io uniwill_wmi || true
          /run/current-system/sw/bin/modprobe uniwill_wmi
          /run/current-system/sw/bin/modprobe tuxedo_io
          /run/current-system/sw/bin/systemctl start tailord.service
          # 不再盲等 3s：轮询等待 tailord 的 DBus 方法可服务（实测首次调用会阻塞到 fan 初始化完成）
          # 每次调用限 2s 超时，成功即退；最多等 30s，超时则失败以便 systemd 标记
          for i in $(seq 1 60); do
            if /run/current-system/sw/bin/busctl call --timeout=2s com.tux.Tailor /com/tux/Tailor com.tux.Tailor.Fan OverrideSpeed yy 0 30 2>/dev/null \
               && /run/current-system/sw/bin/busctl call --timeout=2s com.tux.Tailor /com/tux/Tailor com.tux.Tailor.Fan OverrideSpeed yy 1 30 2>/dev/null; then
              exit 0
            fi
            /run/current-system/sw/bin/sleep 0.5
          done
          echo "tuxedo-fan-resume: tailord DBus not ready after 30s" >&2
          exit 1
        '';
      in [ "${script}" ];
    };
  };
}
