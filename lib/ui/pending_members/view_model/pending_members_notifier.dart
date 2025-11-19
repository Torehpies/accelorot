//import 'package:flutter_application_1/data/repositories/pending_member_repository.dart';
//import 'package:flutter_application_1/ui/pending_members/view_model/pending_members_state.dart';
//import 'package:riverpod_annotation/riverpod_annotation.dart';
//
//part 'pending_members_notifier.g.dart';
//
//@Riverpod(keepAlive: true)
//PendingMemberRepository pendingMemberRepository(Ref ref) {
//	throw UnimplementedError();
//}
//
//@riverpod
//class PendingMembers extends _$PendingMembers {
//	final int _pageSize = 20;
//
//	@override
//	AsyncValue<PendingMembersState> build() {
//		fetchFirstPage();
//		return const AsyncValue.loading();
//	}
//
//  Future<void> fetchFirstPage() async {
//		if (state.isLoading) {
//			state = const AsyncValue.loading();
//		}
//
//		final repository = ref.read(pendingMemberRepositoryProvider);
//
//		try {
//
//		}
//	}
//}
