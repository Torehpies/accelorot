import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';

DataLayerError mapFirebaseAuthException(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return const DataLayerError.permissionError();
		case 'network-request-failed':
      return const DataLayerError.networkError();
		case 'invalid-credential':
      return const DataLayerError.invalidCredentialError();
		case 'too-many-requests':
      return const DataLayerError.tooManyRequestsError();
		case 'popup-closed-by-user':
      return const DataLayerError.popupClosedByUserError();
    default:
			return DataLayerError.unknownError(e);
  }
}
