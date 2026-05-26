import 'package:intl/intl.dart';

String formatChatTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inDays == 0) return DateFormat.Hm().format(time);
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return DateFormat.E().format(time);
  return DateFormat('dd/MM/yy').format(time);
}

String formatDuration(Duration duration) {
  final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

String formatAudioMs(int ms) {
  final d = Duration(milliseconds: ms);
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return m > 0 ? '$m:$s' : '0:$s';
}
