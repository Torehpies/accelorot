import 'package:flutter_application_1/data/repositories/psgc_repository/psgc_repository.dart';
import 'package:flutter_application_1/data/repositories/psgc_repository/psgc_repository_remote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'psgc_providers.g.dart';

@riverpod
PsgcRepository psgcRepository(Ref ref) {
  return PsgcRepositoryRemote();
}
