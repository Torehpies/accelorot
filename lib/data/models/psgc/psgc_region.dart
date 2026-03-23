import 'package:freezed_annotation/freezed_annotation.dart';

part 'psgc_region.freezed.dart';
part 'psgc_region.g.dart';

@freezed
abstract class PsgcRegion with _$PsgcRegion {
  const factory PsgcRegion({
    required String code,
    required String name,
    required String regionName,
  }) = _PsgcRegion;

  factory PsgcRegion.fromJson(Map<String, dynamic> json) =>
      _$PsgcRegionFromJson(json);
}
