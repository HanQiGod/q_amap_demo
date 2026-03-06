import 'dart:async';

import 'package:q_amap_flutter/q_amap_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const QAmapDemoApp());
}

class QAmapDemoApp extends StatelessWidget {
  const QAmapDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QAmap Flutter Federated Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B8043)),
      ),
      home: const QAmapDemoPage(),
    );
  }
}

class QAmapDemoPage extends StatefulWidget {
  const QAmapDemoPage({super.key});

  @override
  State<QAmapDemoPage> createState() => _QAmapDemoPageState();
}

class _QAmapDemoPageState extends State<QAmapDemoPage> {
  static const QAmapLatLng _routeOrigin = QAmapLatLng(
    latitude: 31.2304,
    longitude: 121.4737,
  );
  static const QAmapLatLng _routeDestination = QAmapLatLng(
    latitude: 31.2397,
    longitude: 121.4998,
  );

  QAmapMapController? _controller;
  String _status = 'SDK 初始化中...';
  String _searchResult = '暂无检索结果';
  String _reverseGeocodeResult = '暂无逆地理编码结果';
  String _routePlanResult = '暂无路线规划结果';
  final List<String> _events = <String>[];
  StreamSubscription<QAmapLocation>? _locationSubscription;
  bool _isLocationStreaming = false;
  bool _isSdkInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSdk();
  }

  Future<void> _initializeSdk() async {
    try {
      await QAmapFlutter.initialize(
        const QAmapSdkOptions(
          androidKey: 'YOUR_ANDROID_KEY',
          iosKey: 'YOUR_IOS_KEY',
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isSdkInitialized = true;
        _status = 'SDK 初始化完成（请替换 YOUR_ANDROID_KEY / YOUR_IOS_KEY）';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSdkInitialized = false;
        _status = 'SDK 初始化失败: $error';
      });
    }
  }

  bool _ensureSdkReady() {
    if (_isSdkInitialized) {
      return true;
    }
    if (mounted) {
      setState(() {
        _status = 'SDK 尚未初始化完成，请稍后重试';
      });
    }
    return false;
  }

  Future<void> _moveToShanghai() async {
    final QAmapMapController? controller = _controller;
    if (controller == null) {
      return;
    }
    await controller.moveCamera(
      QAmapCameraUpdate.newCameraPosition(
        const QAmapCameraPosition(target: _routeOrigin, zoom: 13),
      ),
    );
  }

  List<QAmapLatLng> _resolveRoutePolyline(QAmapRoutePath? path) {
    if (path == null) {
      return const <QAmapLatLng>[_routeOrigin, _routeDestination];
    }
    if (path.polyline.isNotEmpty) {
      return path.polyline;
    }

    final List<QAmapLatLng> fallback = <QAmapLatLng>[];
    for (final QAmapRouteStep step in path.steps) {
      fallback.addAll(step.polyline);
    }
    if (fallback.isNotEmpty) {
      return fallback;
    }
    return const <QAmapLatLng>[_routeOrigin, _routeDestination];
  }

  Future<void> _planDrivingRoute() async {
    if (!_ensureSdkReady()) {
      return;
    }
    final QAmapMapController? controller = _controller;
    if (controller == null) {
      return;
    }

    try {
      final QAmapRoutePlanResult? routeResult = await QAmapFlutter.planRoute(
        const QAmapRoutePlanRequest(
          origin: _routeOrigin,
          destination: _routeDestination,
          mode: QAmapRouteTravelMode.driving,
          includeSteps: true,
          includePolyline: true,
        ),
      );

      final QAmapRoutePath? firstPath =
          routeResult == null || routeResult.paths.isEmpty
          ? null
          : routeResult.paths.first;
      final List<QAmapLatLng> polyline = _resolveRoutePolyline(firstPath);

      await controller.updateOverlays(
        QAmapOverlayBatch(
          markers: const <QAmapMarkerOptions>[
            QAmapMarkerOptions(
              id: 'start',
              position: _routeOrigin,
              title: '起点',
            ),
            QAmapMarkerOptions(
              id: 'end',
              position: _routeDestination,
              title: '终点',
            ),
          ],
          polylines: <QAmapPolylineOptions>[
            QAmapPolylineOptions(
              id: 'route-plan',
              points: polyline,
              width: 10,
              colorValue: 0xFF147D64,
            ),
          ],
        ),
      );

      await controller.moveCamera(
        QAmapCameraUpdate.newCameraPosition(
          const QAmapCameraPosition(target: _routeOrigin, zoom: 13),
        ),
      );

      if (!mounted) {
        return;
      }
      final String summary;
      if (firstPath == null) {
        summary = '路线规划成功，但未返回有效路线。';
      } else {
        final String distanceKm = (firstPath.distanceMeters / 1000)
            .toStringAsFixed(1);
        final int minutes = (firstPath.durationSeconds / 60).round();
        final int pathCount = routeResult?.paths.length ?? 1;
        summary = '驾车约 ${distanceKm}km，约 $minutes 分钟（方案数: $pathCount）';
      }

      setState(() {
        _routePlanResult = summary;
        _status = '路线规划完成';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _routePlanResult = '路线规划失败: $error';
      });
    }
  }

  Future<void> _startNavigation() async {
    if (!_ensureSdkReady()) {
      return;
    }
    try {
      final bool launchedNative = await QAmapFlutter.startNavigation(
        const QAmapNavigationRequest(
          origin: _routeOrigin,
          originName: '人民广场',
          destination: _routeDestination,
          destinationName: '外滩',
          mode: QAmapRouteTravelMode.driving,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _status = launchedNative ? '已调起高德 App 导航' : '未安装高德 App，已打开网页导航';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = '启动导航失败: $error';
      });
    }
  }

  Future<void> _locate() async {
    if (!_ensureSdkReady()) {
      return;
    }
    try {
      final QAmapLocation? location = await QAmapFlutter.getCurrentLocation();
      if (!mounted) {
        return;
      }
      setState(() {
        if (location == null) {
          _status = '当前定位：未返回';
        } else {
          _status =
              '当前定位：${location.position.latitude}, ${location.position.longitude}';
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = '单次定位失败: $error';
      });
    }
  }

  Future<void> _startLocationStream() async {
    if (!_ensureSdkReady()) {
      return;
    }
    if (_isLocationStreaming) {
      return;
    }
    await _locationSubscription?.cancel();
    _locationSubscription = QAmapFlutter.locationUpdates().listen(
      (QAmapLocation location) {
        if (!mounted) {
          return;
        }
        setState(() {
          _status =
              '连续定位：${location.position.latitude}, ${location.position.longitude}';
        });
      },
      onError: (Object error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _status = '连续定位流异常: $error';
        });
      },
    );

    try {
      await QAmapFlutter.startLocationUpdates();
      if (!mounted) {
        return;
      }
      setState(() {
        _isLocationStreaming = true;
      });
    } catch (error) {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
      if (!mounted) {
        return;
      }
      setState(() {
        _isLocationStreaming = false;
        _status = '启动连续定位失败: $error';
      });
    }
  }

  Future<void> _stopLocationStream() async {
    try {
      await QAmapFlutter.stopLocationUpdates();
    } finally {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
      if (mounted) {
        setState(() {
          _isLocationStreaming = false;
        });
      }
    }
  }

  Future<void> _searchCoffee() async {
    if (!_ensureSdkReady()) {
      return;
    }
    try {
      final List<QAmapPoi> pois = await QAmapFlutter.searchPoi(
        const QAmapPoiSearchRequest(keyword: '咖啡', city: '上海'),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _searchResult = pois.isEmpty
            ? '搜索为空'
            : '${pois.first.name} (${pois.length} 条)';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchResult = 'POI 检索失败: $error';
      });
    }
  }

  Future<void> _reverseGeocodeBund() async {
    if (!_ensureSdkReady()) {
      return;
    }
    try {
      final QAmapReverseGeocodeResult? result =
          await QAmapFlutter.reverseGeocode(
            const QAmapReverseGeocodeRequest(
              location: QAmapLatLng(latitude: 31.2400, longitude: 121.4900),
            ),
          );
      if (!mounted) {
        return;
      }
      setState(() {
        if (result == null) {
          _reverseGeocodeResult = '逆地理编码为空';
          return;
        }
        _reverseGeocodeResult =
            '${result.formattedAddress}（周边 POI: ${result.pois.length}）';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _reverseGeocodeResult = '逆地理编码失败: $error';
      });
    }
  }

  @override
  void dispose() {
    unawaited(_locationSubscription?.cancel());
    unawaited(
      QAmapFlutter.stopLocationUpdates().catchError((Object _) {
        // Ignore in tests where no concrete platform implementation is registered.
      }),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QAmap Flutter Federated Demo')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: QAmapMapView(
                  options: const QAmapMapInitOptions(
                    initialCamera: QAmapCameraPosition(
                      target: QAmapLatLng(
                        latitude: 39.909187,
                        longitude: 116.397451,
                      ),
                      zoom: 11,
                    ),
                  ),
                  onMapCreated: (QAmapMapController controller) {
                    setState(() {
                      _controller = controller;
                    });
                  },
                  onMapEvent: (QAmapMapEvent event) {
                    setState(() {
                      _events.insert(0, '${event.type}: ${event.payload}');
                      if (_events.length > 5) {
                        _events.removeRange(5, _events.length);
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: _moveToShanghai,
                  child: const Text('移动镜头'),
                ),
                FilledButton(
                  onPressed: _isSdkInitialized ? _planDrivingRoute : null,
                  child: const Text('路线规划'),
                ),
                FilledButton(
                  onPressed: _isSdkInitialized ? _startNavigation : null,
                  child: const Text('开始导航'),
                ),
                FilledButton(
                  onPressed: _isSdkInitialized ? _locate : null,
                  child: const Text('获取定位'),
                ),
                FilledButton(
                  onPressed: _isSdkInitialized && !_isLocationStreaming
                      ? _startLocationStream
                      : null,
                  child: const Text('开始连续定位'),
                ),
                FilledButton(
                  onPressed: _isLocationStreaming ? _stopLocationStream : null,
                  child: const Text('停止连续定位'),
                ),
                FilledButton(
                  onPressed: _isSdkInitialized ? _searchCoffee : null,
                  child: const Text('POI 检索'),
                ),
                FilledButton(
                  onPressed: _isSdkInitialized ? _reverseGeocodeBund : null,
                  child: const Text('逆地理编码'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('状态: $_status'),
                const SizedBox(height: 4),
                Text('连续定位: ${_isLocationStreaming ? '进行中' : '未启动'}'),
                const SizedBox(height: 4),
                Text('检索: $_searchResult'),
                const SizedBox(height: 4),
                Text('逆地理编码: $_reverseGeocodeResult'),
                const SizedBox(height: 4),
                Text('路线规划: $_routePlanResult'),
                const SizedBox(height: 8),
                const Text('最近地图事件:'),
                for (final String line in _events)
                  Text(line, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
