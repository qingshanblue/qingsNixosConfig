# 系统维护任务：定时关机等由系统调度器执行的例行任务。

{ config, pkgs, ... }:

{
  services.cron = {
    enable = true;
    systemCronJobs = [
      "00 01 * * * root /run/current-system/sw/bin/shutdown -h +3 \"System auto shutdown in 3 minutes...\""
    ];
  };
}
