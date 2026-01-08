import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    }
    throw UnsupportedError('TimestampConverter: Unsupported type');
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}
