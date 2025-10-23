import '../models/admin_user_model.dart';

class MockAdminData {
  // Mock stats
  static AdminStats getStats() {
    return AdminStats(
      userCount: 25,
      machineCount: 25,
    );
  }

  // Mock users
  static List<AdminUserModel> getUsers() {
    return [
      AdminUserModel(
        id: '1',
        name: 'Elijah Reyes',
        imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        email: 'elijah.reyes@example.com',
        role: 'Admin',
      ),
      AdminUserModel(
        id: '2',
        name: 'Zoe yap',
        imageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
        email: 'zoe.yap@example.com',
        role: 'User',
      ),
      AdminUserModel(
        id: '3',
        name: 'Avrielle ford',
        imageUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
        email: 'avrielle.ford@example.com',
        role: 'User',
      ),
      AdminUserModel(
        id: '4',
        name: 'Troy m',
        imageUrl: 'https://randomuser.me/api/portraits/men/4.jpg',
        email: 'troy.m@example.com',
        role: 'User',
      ),
      AdminUserModel(
        id: '5',
        name: 'Sarah Johnson',
        imageUrl: 'https://randomuser.me/api/portraits/women/5.jpg',
        email: 'sarah.johnson@example.com',
        role: 'User',
      ),
      AdminUserModel(
        id: '6',
        name: 'Michael Chen',
        imageUrl: 'https://randomuser.me/api/portraits/men/6.jpg',
        email: 'michael.chen@example.com',
        role: 'User',
      ),
      AdminUserModel(
        id: '7',
        name: 'Emma Davis',
        imageUrl: 'https://randomuser.me/api/portraits/women/7.jpg',
        email: 'emma.davis@example.com',
        role: 'Operator',
      ),
      AdminUserModel(
        id: '8',
        name: 'James Wilson',
        imageUrl: 'https://randomuser.me/api/portraits/men/8.jpg',
        email: 'james.wilson@example.com',
        role: 'Operator',
      ),
    ];
  }

  // Get users for a specific section (can be used for different groups)
  static List<AdminUserModel> getUsersForSection(int sectionIndex) {
    final allUsers = getUsers();
    
    // Return different subsets for different sections
    if (sectionIndex == 0) {
      return allUsers.sublist(0, 4);
    } else if (sectionIndex == 1) {
      return allUsers.sublist(4, 8);
    }
    
    return allUsers;
  }
}