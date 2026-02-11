import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/utils/format.dart' as fmt;
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('toTitleCase', () {
    test('should capitalize each word and lower the rest', () {
      expect(fmt.toTitleCase('hello world'), 'Hello World');
      expect(fmt.toTitleCase('hELLo WoRLD'), 'Hello World');
    });

    test('should preserve multiple spaces as single separators in output', () {
      expect(fmt.toTitleCase('  multiple   spaces\tand\nlines  '), '  Multiple   Spaces\tand\nlines  ');
    });

    test('should return empty string when input is empty', () {
      expect(fmt.toTitleCase(''), '');
    });
  });

  group('formatDate', () {
    test('should format valid date as YYYY-MM-DD with zero padding', () {
      expect(fmt.formatDate(DateTime(2024, 1, 9)), '2024-01-09');
      expect(fmt.formatDate(DateTime(1999, 12, 31)), '1999-12-31');
    });

    test('should return Unknown when date is null', () {
      expect(fmt.formatDate(null), 'Unknown');
    });
  });

  group('formatTimestamp (Firestore)', () {
    test('should return Unknown for null timestamp', () {
      expect(fmt.formatTimestamp(null), 'Unknown');
    });

    test('should format timestamp with date and time zero padded', () {
      final ts = Timestamp.fromDate(DateTime(2023, 7, 6, 9, 5));
      expect(fmt.formatTimestamp(ts), '2023-07-06 09:05');
    });
  });

  group('formatDateAndTime (relative formatting)', () {
    test('should format today as time only', () {
      final now = DateTime.now();
      final ds = DateTime(now.year, now.month, now.day, 14, 30);
      final result = fmt.formatDateAndTime(ds);
      expect(result.contains('AM') || result.contains('PM'), isTrue);
    });

    test('should format yesterday with prefix Yesterday', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final ds = DateTime(yesterday.year, yesterday.month, yesterday.day, 8, 15);
      final result = fmt.formatDateAndTime(ds);
      expect(result.startsWith('Yesterday '), isTrue);
    });

    test('should format within last 7 days with weekday name', () {
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      final ds = DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day, 10, 0);
      final result = fmt.formatDateAndTime(ds);
      // Expect a three-letter weekday prefix like Mon, Tue, etc
      final weekdayRegex = RegExp(r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun) ');
      expect(weekdayRegex.hasMatch(result), isTrue);
    });

    test('should format older dates with full month format', () {
      final old = DateTime(2020, 2, 29, 23, 59);
      final result = fmt.formatDateAndTime(old);
      // Example: Feb 29, 2020 11:59 PM
      final regex = RegExp(r'^[A-Za-z]{3} \d{2}, \d{4}');
      expect(regex.hasMatch(result), isTrue);
    });
  });
}
