import 'package:flutter_application_1/ui/team_management/widgets/team_management_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_management_notifier.g.dart';

@riverpod
class TeamManagementNotifier extends _$TeamManagementNotifier {
	@override
	TeamManagementState build() {
		return const TeamManagementState();
	}
  
}
