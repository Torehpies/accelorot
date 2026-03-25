import 'package:freezed_annotation/freezed_annotation.dart';

part 'psgc_city_municipality.freezed.dart';
part 'psgc_city_municipality.g.dart';

@freezed
abstract class PsgcCityMunicipality with _$PsgcCityMunicipality {
  const factory PsgcCityMunicipality({
    required String code,
    required String name,
    required String? provinceCode,
    required String? regionCode,
    @Default(true) bool isCity,
  }) = _PsgcCityMunicipality;

  factory PsgcCityMunicipality.fromJson(Map<String, dynamic> json) =>
      _$PsgcCityMunicipalityFromJson(json);
}
