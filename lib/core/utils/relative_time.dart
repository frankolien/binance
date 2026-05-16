/// Compact relative time formatter — Twitter-style: `12s`, `4m`, `3h`, `2d`,
/// then `Mar 5` for >7 days, `Mar 5 2024` if a different year.
String formatRelativeTime(DateTime time, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(time);

  if (diff.isNegative) return 'now';
  if (diff.inSeconds < 60) return '${diff.inSeconds}s';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final m = months[time.month - 1];
  if (time.year == reference.year) return '$m ${time.day}';
  return '$m ${time.day} ${time.year}';
}
