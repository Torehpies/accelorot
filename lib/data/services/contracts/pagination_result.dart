class PaginationResult<T> {
  final List<T> items;
  final String? nextCursor;

  PaginationResult({required this.items, this.nextCursor});
}
