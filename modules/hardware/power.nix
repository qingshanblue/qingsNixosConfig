# 电源管理与合盖策略。

{ config, pkgs, ... }:

{
  services.logind.settings = {
    Login = {
      IdleAction = "lock";
      IdleActionUSec = "10min";
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
  };
}
