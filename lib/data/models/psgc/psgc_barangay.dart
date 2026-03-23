import 'package:freezed_annotation/freezed_annotation.dart';

part 'psgc_barangay.freezed.dart';
part 'psgc_barangay.g.dart';

@freezed
abstract class PsgcBarangay with _$PsgcBarangay {
  const factory PsgcBarangay({
    required String code,
    required String name,
    required String? cityCode,
    required String? municipalityCode,
  }) = _PsgcBarangay;

  factory PsgcBarangay.fromJson(Map<String, dynamic> json) =>
      _$PsgcBarangayFromJson(json);
}
