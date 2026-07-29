import 'package:dtn_chat/core/constants/app_urls.dart';
import 'package:logger/logger.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';
import 'auth_service.dart';

class ReverbService {
  static var logger = Logger();
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
    await client.connect();
    logger.i("reverb connected");
  }

  static void listen() {
    final channel = client.subscribeToChannel('test');

    channel.on('test.message').listen((event) {
      logger.i("🔥 Reverb event: ${event.data}");
    });
  }

  static void disconnect() {
    client.disconnect();
  }
}
