import 'package:flutter/material.dart';
import '../../../data/models/operator_model.dart';

class UserSelectorDropdown extends StatelessWidget {
  final List<OperatorModel> users;
  final List<String> selectedUserIds;
  final Function(List<String>) onSelectionChanged;
  final bool enabled;

  const UserSelectorDropdown({
    super.key,
    required this.users,
    required this.selectedUserIds,
    required this.onSelectionChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _showUserSelectionDialog(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey[50] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.people_outline, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getDisplayText(),
                style: TextStyle(
                  fontSize: 14,
                  color: selectedUserIds.isEmpty
                      ? Colors.grey[600]
                      : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: enabled ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (selectedUserIds.isEmpty) {
      return 'All Team Members';
    } else if (selectedUserIds.length == users.length) {
      return 'All Team Members';
    } else if (selectedUserIds.length == 1) {
      final user = users.firstWhere((u) => u.id == selectedUserIds.first);
      return user.name;
    } else {
      return '${selectedUserIds.length} users selected';
    }
  }

  Future<void> _showUserSelectionDialog(BuildContext context) async {
    final tempSelected = List<String>.from(selectedUserIds);
    bool selectAll = tempSelected.length == users.length;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        'Assign Users',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Select All Option
                  CheckboxListTile(
                    value: selectAll,
                    onChanged: (value) {
                      setState(() {
                        selectAll = value ?? false;
                        if (selectAll) {
                          tempSelected.clear();
                          tempSelected.addAll(users.map((u) => u.id));
                        } else {
                          tempSelected.clear();
                        }
                      });
                    },
                    title: const Text(
                      'All Team Members',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF4CAF50),
                  ),
                  const Divider(),

                  // User List
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isSelected = tempSelected.contains(user.id);

                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                tempSelected.add(user.id);
                              } else {
                                tempSelected.remove(user.id);
                              }
                              selectAll = tempSelected.length == users.length;
                            });
                          },
                          title: Text(user.name),
                          subtitle: Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: const EdgeInsets.only(left: 8),
                          activeColor: const Color(0xFF4CAF50),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onSelectionChanged(tempSelected);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
