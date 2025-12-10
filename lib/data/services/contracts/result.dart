import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
abstract class Result<T, E> with _$Result<T, E> {
  const factory Result.success(T data) = Success<T, E>;
  const factory Result.failure(E failure) = Failure<T, E>;

  const Result._();

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  E get asFailure => (this as Failure<T, E>).failure;
  T get asSuccess => (this as Success<T, E>).data;
}
