import 'dart:io';

import 'package:dtn_chat/core/constants/app_urls.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';
import 'auth_service.dart';

class ReverbService {
  static bool _connected = false;
  static final client = ReverbClient.instance(
    host: AppUrls.reverb_url,
    port: AppUrls.reverb_port,
    appKey: AppUrls.REVERB_APP_KEY,
    authEndpoint: '${AppUrls.api_url}/api/broadcasting/auth',
    authorizer: (channelName, socketId) async {
      return {
        'Authorization': 'Bearer ${AuthService.token}',
        'Accept': 'application/json',
      };
    },
  );

  static Future<bool> _isReverbReachable() async {
    try {
      final socket = await Socket.connect(
        AppUrls.reverb_url,
        AppUrls.reverb_port,
        timeout: const Duration(seconds: 2),
      );

      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> connect() async {
    if (_connected) return true;

    if (!await _isReverbReachable()) {
      return false;
    }

    try {
      final state = client.onConnectionStateChange;

      await client.connect();

      await for (final connectionState in state) {
        if (connectionState == ConnectionState.connected) {
          _connected = true;
          return true;
        }

        if (connectionState == ConnectionState.error) {
          return false;
        }
      }
    } catch (_) {
      _connected = false;
      return false;
    }

    return false;
  }

  static void listen() {
    final channel = client.subscribeToChannel('test');

    channel.on('test.message').listen((event) {
      // logger.i("1111111111111 🔥 Reverb event: ${event.data}");
    });
  }

  static void disconnect() {
    client.disconnect();
  }
}
