import 'package:dtn_chat/core/constants/app_urls.dart';
import 'package:logger/logger.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';
import 'auth_service.dart';

class ReverbService {
  static var logger = Logger();
  static bool _connected = false;
  static final client = ReverbClient.instance(
    host: '10.0.2.2',
    port: 8081,
    appKey: 'jjsxpvyww0vgmmql60um',
    authEndpoint: 'http://10.0.2.2:8000/api/broadcasting/auth',
    authorizer: (channelName, socketId) async {
      return {
        'Authorization': 'Bearer ${AuthService.token}',
        'Accept': 'application/json',
      };
    },
  );

  static Future<void> connect() async {
    if (_connected) return;

    final state = client.onConnectionStateChange;

    await client.connect();

    await for (final connectionState in state) {
      // logger.i("Reverb state: $connectionState");

      if (connectionState == ConnectionState.connected) {
        _connected = true;
        // logger.i("Reverb connected");
        break;
      }

      if (connectionState == ConnectionState.error) {
        throw Exception("Failed to connect to Reverb");
      }
    }
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
