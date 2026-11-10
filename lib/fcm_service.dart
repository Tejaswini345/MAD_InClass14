import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Owns every FCM listener. The UI only listens to this ChangeNotifier.
class FCMService extends ChangeNotifier {
  FCMService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  /// Allow-list: payload `asset` value -> bundled asset path.
  /// Unknown values are rejected, so we never build an invalid asset path.
  static const Map<String, String> supportedAssets = {
    'default': 'assets/images/default.png',
    'promo': 'assets/images/promo.png',
  };
  static const String supportedAction = 'update_ui';

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _tokenSub;
  bool _initialized = false;
  bool _disposed = false;

  // ----- state shown in the UI -----
  String title = 'Cloud Courier';
  String assetKey = 'default';
  String lastHandler = 'none yet';
  int receiptCount = 0;
  String messageId = '-';
  String diagnostic = 'Waiting for a message...';
  bool lastWasValid = true;
  String? token;
  String permission = 'unknown';

  String get assetPath => supportedAssets[assetKey]!;

  /// Call once from the widget that owns this service.
  Future<void> initialize() async {
    if (_initialized) return; // prevents duplicate listeners
    _initialized = true;

    try {
      final settings = await _messaging.requestPermission();
      permission = settings.authorizationStatus.name;
    } catch (e) {
      permission = 'error: $e';
    }

    try {
      token = await _messaging.getToken();
      debugPrint('[FCM token] $token');
    } catch (e) {
      debugPrint('[FCM token] failed: $e');
    }
    _tokenSub = _messaging.onTokenRefresh.listen((t) {
      token = t;
      _notify();
    });

    // Foreground receipt.
    _onMessageSub = FirebaseMessaging.onMessage
        .listen((m) => _handle(m, 'onMessage'));
    // Background -> user taps notification.
    _openedSub = FirebaseMessaging.onMessageOpenedApp
        .listen((m) => _handle(m, 'onMessageOpenedApp'));
    // Terminated -> user taps notification (cold start). Null on normal launch.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handle(initial, 'getInitialMessage');

    _notify();
  }

  void _handle(RemoteMessage message, String handler) {
    lastHandler = handler;
    receiptCount++;
    messageId = message.messageId ?? '-';
    final data = message.data;
    debugPrint('[$handler] id=$messageId data=$data');

    final action = data['action'];
    final asset = data['asset'];

    if (action != supportedAction) {
      _reject('Rejected: action "${action ?? 'MISSING'}" is not "$supportedAction".');
    } else if (asset == null) {
      _reject('Rejected: required key "asset" is missing.');
    } else if (!supportedAssets.containsKey(asset)) {
      _reject('Rejected: unsupported asset "$asset". '
          'Allowed: ${supportedAssets.keys.join(', ')}.');
    } else {
      assetKey = asset;
      title = message.notification?.title ?? data['title'] ?? title;
      diagnostic = 'OK: applied asset "$asset".';
      lastWasValid = true;
    }
    _notify();
  }

  /// Keep previous title/image; only metadata + diagnostic change.
  void _reject(String reason) {
    diagnostic = reason;
    lastWasValid = false;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _onMessageSub?.cancel();
    _openedSub?.cancel();
    _tokenSub?.cancel();
    super.dispose();
  }
}
