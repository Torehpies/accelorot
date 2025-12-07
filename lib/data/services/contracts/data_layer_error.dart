import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_layer_error.freezed.dart';

@freezed
abstract class DataLayerError with _$DataLayerError {
  const DataLayerError._();

  const factory DataLayerError.networkError() = NetworkError;
  const factory DataLayerError.permissionError() = PermissionError;
  const factory DataLayerError.databaseError({required String message}) =
      DatabaseError;
  const factory DataLayerError.mappingError() = MappingError;
  const factory DataLayerError.userExistsError() = UserExistsError;
  const factory DataLayerError.dataEmptyError() = DataEmptyError;
  const factory DataLayerError.emailVerificationError() =
      EmailVerificationError;
  const factory DataLayerError.emailNotVerifiedError() = EmailNotVerifiedError;
  const factory DataLayerError.validationError({required String message}) =
      ValidationError;
  const factory DataLayerError.unknownError([Object? error]) = UnknownError;

  String get userFriendlyMessage => when(
    networkError: () => 'Connection failed or server is unreachable.',
    permissionError: () => 'Insufficient permissions or unauthenticated.',
    databaseError: (message) => message,
    mappingError: () => 'Data recieved from the server was corrupt.',
    userExistsError: () => 'User already exists in database.',
    dataEmptyError: () => 'Fetched data is empty.',
    validationError: (message) => message,
    unknownError: (_) => 'An unexpected error occurred. Please try again',
    emailVerificationError: () => 'Email verification error.',
    emailNotVerifiedError: () => 'Email not verified.',
  );
}
