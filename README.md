# q_amap

Flutter 自研高德地图插件骨架（federated plugin）示例。

## 目录结构

- `packages/q_amap_flutter`：对业务方暴露的 Flutter API（Widget + Controller）。
- `packages/q_amap_flutter_platform_interface`：跨平台统一抽象与数据模型。
- `packages/q_amap_flutter_android`：Android 实现（MethodChannel + PlatformView 占位）。
- `packages/q_amap_flutter_ios`：iOS 实现（MethodChannel + PlatformView 占位）。
- 根目录 `lib/main.dart`：接入演示 Demo。

## 快速开始

1. 在根项目执行 `flutter pub get`。
2. 将 `lib/main.dart` 内 `YOUR_ANDROID_KEY` / `YOUR_IOS_KEY` 替换为真实 key。
3. 执行 `flutter run`。

## 当前状态

- 已具备插件分层架构和首批 API：地图视图、相机控制、覆盖物更新、地图事件、定位、POI 检索与逆地理编码。
- Android / iOS 已接入高德原生 SDK 的 POI 检索与逆地理编码能力，可直接通过 Flutter API 调用。
- Android / iOS 已支持路线规划（驾车/步行/骑行/公交）与导航拉起（优先高德 App，失败回退网页）。
- 已补齐能力对齐文档、集成测试基线与 Dart 层性能监控接入。

## 文档入口

- 能力对齐：`docs/capability_alignment.md`
- 性能监控：`docs/performance_monitoring.md`