String formatTimestamp(DateTime date) {
  final month = monthString(date.month);
  final ampm = date.hour >= 12 ? 'PM' : 'AM';
  final displayHour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  return '$month ${date.day}, $displayHour:$minute $ampm';
}

String monthString(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month - 1];
}

String capitalize(String? txt) {
  if (txt == null || txt.isEmpty) return '';
  return txt[0].toUpperCase() + txt.substring(1);
}
