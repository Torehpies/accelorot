import 'package:flutter_application_1/data/services/contracts/machine_service.dart';

/// TODO future local db for offline use
class LocalMachineService implements MachineService{
  @override
  Future<Map<String, dynamic>> fetchRawMachineData(String id) {
    // TODO: implement fetchRawMachineData
    throw UnimplementedError();
  }

}
