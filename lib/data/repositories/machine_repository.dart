import 'package:flutter_application_1/data/services/contracts/machine_service.dart';

abstract class MachineRepository {
	//Future<Machine> getMachine(String id) async {
	//	return Machine(...);
	//}
}

class MachineRepositoryImpl implements MachineRepository {

	final MachineService machineService;

	MachineRepositoryImpl(this.machineService);

	//@override
	//Future<Machine> getMachine(String id) async {
	//	return Machine(...);
	//}
}
