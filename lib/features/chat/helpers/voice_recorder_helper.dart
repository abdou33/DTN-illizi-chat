import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/media_utils.dart';
import '../../../core/utils/ui_utils.dart';

class VoiceRecorderHelper {
  final AudioRecorder recorder = AudioRecorder();
  final AudioPlayer player = AudioPlayer();

  bool isRecording = false;
  Duration recordDuration = Duration.zero;
  String? playingMessageId;

  DateTime? _startedAt;
  Timer? _timer;
  StreamSubscription<void>? _playerSub;

  void init(VoidCallback onUpdate) {
    _playerSub = player.onPlayerComplete.listen((_) {
      playingMessageId = null;
      onUpdate();
    });
  }

  void dispose() {
    _timer?.cancel();
    _playerSub?.cancel();
    recorder.dispose();
    player.dispose();
  }

  Future<bool> ensurePermission(BuildContext context) async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    status = await Permission.microphone.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      showAppSnackBar(context, 'Enable microphone in app settings.', isError: true);
      await openAppSettings();
    } else {
      showAppSnackBar(context, 'Microphone permission is required.', isError: true);
    }
    return false;
  }

  void _startTimer(VoidCallback onUpdate) {
    _startedAt = DateTime.now();
    recordDuration = Duration.zero;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startedAt != null) {
        recordDuration = DateTime.now().difference(_startedAt!);
        onUpdate();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _startedAt = null;
    recordDuration = Duration.zero;
  }

  Future<String?> start(BuildContext context, VoidCallback onUpdate) async {
    if (!await ensurePermission(context)) return null;
    if (!await recorder.hasPermission()) {
      showAppSnackBar(context, 'Microphone not available.', isError: true);
      return null;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    isRecording = true;
    _startTimer(onUpdate);
    onUpdate();
    return path;
  }

  Future<({String path, int durationMs})?> stop(BuildContext context) async {
    final durationMs = recordDuration.inMilliseconds;
    _stopTimer();
    final path = await recorder.stop();
    isRecording = false;

    if (path == null || path.isEmpty) return null;
    if (durationMs < 1000) {
      showAppSnackBar(context, 'Voice message must be at least 1 second.', isError: true);
      try {
        await File(path).delete();
      } catch (_) {}
      return null;
    }
    return (path: path, durationMs: durationMs);
  }

  String get recordingLabel => 'Recording ${formatDuration(recordDuration)}';

  Future<void> togglePlayback(String url, String messageId, VoidCallback onUpdate) async {
    if (playingMessageId == messageId) {
      await player.stop();
      playingMessageId = null;
    } else {
      await player.stop();
      if (isLocalMediaPath(url)) {
        await player.play(DeviceFileSource(url));
      } else {
        await player.play(UrlSource(url));
      }
      playingMessageId = messageId;
    }
    onUpdate();
  }
}
