import 'package:freezed_annotation/freezed_annotation.dart';

part 'psgc_province.freezed.dart';
part 'psgc_province.g.dart';

@freezed
abstract class PsgcProvince with _$PsgcProvince {
  const factory PsgcProvince({
    required String code,
    required String name,
    required String regionCode,
  }) = _PsgcProvince;

  factory PsgcProvince.fromJson(Map<String, dynamic> json) =>
      _$PsgcProvinceFromJson(json);
}
