abstract class DataLayerError implements Exception {
	final String message;
	const DataLayerError(this.message);
}

class NetworkError extends DataLayerError {
	const NetworkError() : super('Connection failed or server is unreachable.');
}

class PermissionError extends DataLayerError {
  const PermissionError() : super('Insufficient permissions or unauthenticated.');
}

class MappingError extends DataLayerError {
  const MappingError() : super('Data recieved from the server was corrupt.');
}

class UserExistsError extends DataLayerError {
  const UserExistsError() : super('User already exists in database.');
}
