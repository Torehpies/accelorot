import 'package:flutter_application_1/data/models/psgc/psgc_barangay.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_city_municipality.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_province.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_region.dart';
import 'package:flutter_application_1/data/providers/psgc_providers.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'psgc_state.freezed.dart';
part 'psgc_state.g.dart';

@freezed
abstract class PsgcState with _$PsgcState {
  const factory PsgcState({
    @Default([]) List<PsgcRegion> regions,
    @Default([]) List<PsgcProvince> provinces,
    @Default([]) List<PsgcCityMunicipality> citiesMunicipalities,
    @Default([]) List<PsgcBarangay> barangays,
    PsgcRegion? selectedRegion,
    PsgcProvince? selectedProvince,
    PsgcCityMunicipality? selectedCityMunicipality,
    PsgcBarangay? selectedBarangay,
    @Default(false) bool isLoading,
    String? error,
  }) = _PsgcState;
}


@riverpod
class PsgcNotifier extends _$PsgcNotifier {
  @override
  PsgcState build() {
    return const PsgcState();
  }

  Future<void> loadRegions() async {
    state = state.copyWith(isLoading: true, error: null);
    final repository = ref.read(psgcRepositoryProvider);
    final result = await repository.getRegions();

    result.when(
      success: (regions) {
        state = state.copyWith(
          regions: regions,
          isLoading: false,
        );
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  Future<void> selectRegion(PsgcRegion? region) async {
    if (state.selectedRegion == region) return;

    state = state.copyWith(
      selectedRegion: region,
      selectedProvince: null,
      selectedCityMunicipality: null,
      selectedBarangay: null,
      provinces: [],
      citiesMunicipalities: [],
      barangays: [],
      isLoading: true,
      error: null,
    );

    if (region != null) {
      final repository = ref.read(psgcRepositoryProvider);
      
      // Fetch provinces
      final provincesResult = await repository.getProvinces(region.code);
      
      provincesResult.when(
        success: (provinces) async {
          if (provinces.isEmpty) {
             // If no provinces (e.g. NCR), fetch cities directly for the region
             final citiesResult = await repository.getCitiesAndMunicipalities(region.code);
             citiesResult.when(
               success: (cities) {
                 state = state.copyWith(
                   provinces: [],
                   citiesMunicipalities: cities,
                   isLoading: false
                 );
               },
               failure: (error) {
                 state = state.copyWith(isLoading: false, error: error.toString());
               }
             );
          } else {
            state = state.copyWith(
              provinces: provinces,
              isLoading: false,
            );
          }
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.toString(),
          );
        },
      );
    } else {
        state = state.copyWith(isLoading: false);
    }
  }

  Future<void> selectProvince(PsgcProvince? province) async {
    if (state.selectedProvince == province) return;

    state = state.copyWith(
      selectedProvince: province,
      selectedCityMunicipality: null,
      selectedBarangay: null,
      citiesMunicipalities: [],
      barangays: [],
      isLoading: true,
      error: null,
    );

    if (province != null) {
      final repository = ref.read(psgcRepositoryProvider);
      final result = await repository.getCitiesAndMunicipalitiesByProvince(province.code);

      result.when(
        success: (cities) {
          state = state.copyWith(
            citiesMunicipalities: cities,
            isLoading: false,
          );
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.toString(),
          );
        },
      );
    } else {
        state = state.copyWith(isLoading: false);
    }
  }

  Future<void> selectCityMunicipality(PsgcCityMunicipality? city) async {
    if (state.selectedCityMunicipality == city) return;

    state = state.copyWith(
      selectedCityMunicipality: city,
      selectedBarangay: null,
      barangays: [],
      isLoading: true,
      error: null,
    );

    if (city != null) {
      final repository = ref.read(psgcRepositoryProvider);
      
      // Use the isCity flag to determine which endpoint to call
      final result = city.isCity
          ? await repository.getBarangaysByCityCode(city.code)
          : await repository.getBarangaysByMunicipalityCode(city.code);

      result.when(
        success: (barangays) {
          state = state.copyWith(
            barangays: barangays,
            isLoading: false,
          );
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.toString(),
          );
        },
      );
    } else {
        state = state.copyWith(isLoading: false);
    }
  }

  void selectBarangay(PsgcBarangay? barangay) {
    state = state.copyWith(selectedBarangay: barangay);
  }
}
