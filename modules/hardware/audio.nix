# 音频：PipeWire 体系、ALSA 及其 32 位兼容、PulseAudio 模拟。

{ config, pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
