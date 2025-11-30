import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';

DataLayerError mapFirebaseException(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return const DataLayerError.permissionError();
		case 'network-request-failed':
      return const DataLayerError.networkError();
    default:
			return DataLayerError.unknownError(e);
  }
}
