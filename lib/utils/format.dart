import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatDateAndTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays == 0) {
    return DateFormat('HH:mm').format(date);
  } else if (diff.inDays == 1) {
    return 'Yesterday ${DateFormat('HH:mm').format(date)}';
  } else if (diff.inDays < 7) {
    return '${DateFormat('EEE').format(date)} ${DateFormat('HH:mm').format(date)}';
  }
  return DateFormat('MMM dd, yyyy h:mm a').format(date);
}

String formatDate(DateTime? date) {
  if (date == null) return 'Unknown';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return 'Unknown';
  final date = timestamp.toDate();
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String toTitleCase(String text) {
  return text
      .split(' ')
      .map(
        (word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word,
      )
      .join(' ');
}
