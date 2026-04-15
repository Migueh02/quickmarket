/// Formato breve en español para listas (sin dependencia `intl`).
String formatRelativeTimeEs(DateTime dateTime) {
  final now = DateTime.now();
  var d = dateTime.toLocal();
  var diff = now.difference(d);
  if (diff.isNegative) diff = Duration.zero;

  if (diff.inSeconds < 60) return 'Ahora mismo';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
  return '${d.day}/${d.month}/${d.year}';
}
