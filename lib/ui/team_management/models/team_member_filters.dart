import '../../core/widgets/filters/mobile_dropdown_filter_button.dart';

/// Team member status filter options for team detail screen
enum TeamMemberStatusFilter implements FilterOption {
  all,
  active,
  removed,
  archived;

  @override
  String get displayName {
    switch (this) {
      case TeamMemberStatusFilter.all:
        return 'All Status';
      case TeamMemberStatusFilter.active:
        return 'Active';
      case TeamMemberStatusFilter.removed:
        return 'Removed';
      case TeamMemberStatusFilter.archived:
        return 'Archived';
    }
  }

  @override
  bool get isAll => this == TeamMemberStatusFilter.all;
}
