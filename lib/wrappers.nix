# 可复用的软件包包装函数
{ pkgs }:

{
  # XWayland 缩放包装器
  # 通过 wrapProgram 为特定二进制注入缩放或显示相关的环境变量
  mkScaled = name: pkg: bin: wrapperArgs:
    pkgs.symlinkJoin {
      inherit name;
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = "wrapProgram $out/bin/${bin} ${wrapperArgs}";
    };
}
