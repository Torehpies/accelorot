import 'package:flutter_application_1/utils/user_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum(valueField: 'value')
enum OperatorHeaders {
  activeOperators('activeOperators'),
  archivedOperators('archivedOperators'),
  formerOperators('formerOperators'),
  pendingOperators('pendingOperators');

  final String value;
  const OperatorHeaders(this.value);
}

OperatorHeaders? mapStatusToOperatorHeader(UserStatus status) {
  switch (status) {
    case UserStatus.active:
      return OperatorHeaders.activeOperators;
    case UserStatus.pending:
    case UserStatus.approval:
      return OperatorHeaders.pendingOperators;
    case UserStatus.archived:
      return OperatorHeaders.archivedOperators;
    case UserStatus.removed:
      return OperatorHeaders.formerOperators;
    default:
      return null;
  }
}
