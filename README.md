# q_amap_demo

`q_amap_demo` 是 `q_amap` 联邦插件体系的宿主演示应用，用来验证地图、定位、搜索、路线、导航占位链路，以及多类场景化渲染能力。

## 作用

- 演示 `q_amap_flutter` 对外 API 的典型接入方式。
- 作为真机联调入口，验证高德 Key、权限、地图渲染与原生桥接是否正常。
- 回归搜索、路线、热力图、瓦片图层、海量点、轨迹回放和 placeholder 内嵌导航等场景。

## 快速开始

1. 在仓库根目录执行 `flutter pub get`。
2. 复制 `env/amap_keys.example.json` 为 `env/amap_keys.local.json`，并填入真实高德 Key。
3. 在仓库根目录执行 `bash tool/run_with_amap_keys.sh`。
4. 进入示例页后，优先验证基础地图、定位、搜索与路线规划链路。

如果需要指定设备，可直接追加参数，例如：

```bash
bash tool/run_with_amap_keys.sh -d ios
```

## 当前覆盖

- 地图：基础地图、相机控制、覆盖物更新、地图事件、截图、样式与显示选项。
- 定位：单次定位、连续定位、状态流、蓝点配置与地理围栏。
- 搜索：关键词、周边、多边形、输入提示、正逆地理编码、行政区、距离测算与天气查询。
- 路线：驾车/步行/骑行/公交规划、多方案落图、step timeline 与步骤聚焦。
- 高级能力：瓦片图层、热力图、海量点/聚合、轨迹回放。
- 导航：外部导航拉起，以及 `M5` placeholder 内嵌导航会话、事件和视图挂载。

## 关联文档

- 根目录接入说明：`../../README.md`
- 能力对齐：`../../docs/capability_alignment.md`
- M5 placeholder 接入说明：`../../docs/m5_placeholder_navigation_integration.md`
- 性能监控：`../../docs/performance_monitoring.md`
