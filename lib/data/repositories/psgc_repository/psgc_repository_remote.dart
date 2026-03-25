import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/data/models/psgc/psgc_barangay.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_city_municipality.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_province.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_region.dart';
import 'package:flutter_application_1/data/repositories/psgc_repository/psgc_repository.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

class PsgcRepositoryRemote implements PsgcRepository {
  static const String _baseUrl = 'https://psgc.gitlab.io/api';

  @override
  Future<Result<List<PsgcRegion>, Exception>> getRegions() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/regions/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final regions = data.map((e) => PsgcRegion.fromJson(e)).toList();
        // Sort alphabetically by name for better UX
        regions.sort((a, b) => a.name.compareTo(b.name));
        return Result.success(regions);
      } else {
        return Result.failure(Exception('Failed to load regions: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Failed to load regions: $e'));
    }
  }

  @override
  Future<Result<List<PsgcProvince>, Exception>> getProvinces(String regionCode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/regions/$regionCode/provinces/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final provinces = data.map((e) => PsgcProvince.fromJson(e)).toList();
        provinces.sort((a, b) => a.name.compareTo(b.name));
        return Result.success(provinces);
      } else {
        return Result.failure(Exception('Failed to load provinces: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Failed to load provinces: $e'));
    }
  }

  @override
  Future<Result<List<PsgcCityMunicipality>, Exception>> getCitiesAndMunicipalities(String regionCode) async {
    try {
      // Fetch both cities and municipalities for the region (e.g. for NCR which has no provinces)
      final citiesResponse = await http.get(Uri.parse('$_baseUrl/regions/$regionCode/cities/'));
      final municipalitiesResponse = await http.get(Uri.parse('$_baseUrl/regions/$regionCode/municipalities/'));
      
      List<PsgcCityMunicipality> allItems = [];

      if (citiesResponse.statusCode == 200) {
        final List<dynamic> citiesData = json.decode(citiesResponse.body);
        allItems.addAll(citiesData.map((e) => PsgcCityMunicipality.fromJson(e).copyWith(isCity: true)));
      }

      if (municipalitiesResponse.statusCode == 200) {
        final List<dynamic> municipalitiesData = json.decode(municipalitiesResponse.body);
        allItems.addAll(municipalitiesData.map((e) => PsgcCityMunicipality.fromJson(e).copyWith(isCity: false)));
      }
      
      allItems.sort((a, b) => a.name.compareTo(b.name));
      return Result.success(allItems);

    } catch (e) {
      return Result.failure(Exception('Failed to load cities/municipalities: $e'));
    }
  }

  @override
  Future<Result<List<PsgcCityMunicipality>, Exception>> getCitiesAndMunicipalitiesByProvince(String provinceCode) async {
    try {
       // Fetch both cities and municipalities for the province
      final citiesResponse = await http.get(Uri.parse('$_baseUrl/provinces/$provinceCode/cities/'));
      final municipalitiesResponse = await http.get(Uri.parse('$_baseUrl/provinces/$provinceCode/municipalities/'));
      
      List<PsgcCityMunicipality> allItems = [];

      if (citiesResponse.statusCode == 200) {
        final List<dynamic> citiesData = json.decode(citiesResponse.body);
        allItems.addAll(citiesData.map((e) => PsgcCityMunicipality.fromJson(e).copyWith(isCity: true)));
      }

      if (municipalitiesResponse.statusCode == 200) {
         final List<dynamic> municipalitiesData = json.decode(municipalitiesResponse.body);
         allItems.addAll(municipalitiesData.map((e) => PsgcCityMunicipality.fromJson(e).copyWith(isCity: false)));
      }
      
      allItems.sort((a, b) => a.name.compareTo(b.name));
      return Result.success(allItems);
    } catch (e) {
      return Result.failure(Exception('Failed to load cities/municipalities: $e'));
    }
  }

  @override
  Future<Result<List<PsgcBarangay>, Exception>> getBarangays(String cityOrMunicipalityCode) async {
     // Try fetching as city first, if empty try municipality (API distinction)
     // Alternatively, the PsgcCityMunicipality object should ideally tell us if it's a city or municipality, 
     // but the API endpoint structure requires us to know.
     // For simplicity in this "generic" method, we might need a flag or try both.
     // Better approach: use specific methods below.
     return Result.failure(Exception("Use specific getBarangaysByCity or getBarangaysByMunicipality"));
  }

  @override
  Future<Result<List<PsgcBarangay>, Exception>> getBarangaysByCityCode(String cityCode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/cities/$cityCode/barangays/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final barangays = data.map((e) => PsgcBarangay.fromJson(e)).toList();
        barangays.sort((a, b) => a.name.compareTo(b.name));
        return Result.success(barangays);
      } else {
        return Result.failure(Exception('Failed to load barangays: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Failed to load barangays: $e'));
    }
  }

   @override
  Future<Result<List<PsgcBarangay>, Exception>> getBarangaysByMunicipalityCode(String municipalityCode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/municipalities/$municipalityCode/barangays/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final barangays = data.map((e) => PsgcBarangay.fromJson(e)).toList();
        barangays.sort((a, b) => a.name.compareTo(b.name));
        return Result.success(barangays);
      } else {
        return Result.failure(Exception('Failed to load barangays: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Failed to load barangays: $e'));
    }
  }
}
