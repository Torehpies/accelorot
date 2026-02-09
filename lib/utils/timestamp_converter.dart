import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();
  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    }
    throw UnsupportedError('Unsupported type: ${json.runtimeType}');
  }
  @override
  Object toJson(DateTime date) {
    return Timestamp.fromDate(date);
  }
}
