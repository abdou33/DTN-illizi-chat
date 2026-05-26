/// Builds display initials from a full name (e.g. "Wakil Hazem" → "WH").
String nameInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final word = parts.first;
    if (word.length >= 2) {
      return word.substring(0, 2).toUpperCase();
    }
    return word[0].toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
