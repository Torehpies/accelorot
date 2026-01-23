import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'operators_search_provider.g.dart';

@riverpod
class OperatorsSearch extends _$OperatorsSearch {
  @override
  String build() => '';

  void setSearch(String query) => state = query;
  void clearSearch() => state = '';
}
