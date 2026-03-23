import 'package:flutter_application_1/data/models/psgc/psgc_barangay.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_city_municipality.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_province.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_region.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class PsgcRepository {
  Future<Result<List<PsgcRegion>, Exception>> getRegions();
  Future<Result<List<PsgcProvince>, Exception>> getProvinces(String regionCode);
  Future<Result<List<PsgcCityMunicipality>, Exception>> getCitiesAndMunicipalities(String regionCode);
  Future<Result<List<PsgcCityMunicipality>, Exception>> getCitiesAndMunicipalitiesByProvince(String provinceCode);
  Future<Result<List<PsgcBarangay>, Exception>> getBarangays(String cityOrMunicipalityCode);
  Future<Result<List<PsgcBarangay>, Exception>> getBarangaysByCityCode(String cityCode);
  Future<Result<List<PsgcBarangay>, Exception>> getBarangaysByMunicipalityCode(String municipalityCode);
}
