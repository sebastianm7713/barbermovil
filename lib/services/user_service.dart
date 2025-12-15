import '../models/user.dart';

class UserService {
  // Lista simulada en memoria
  static final List<User> _users = [
    User(id: 1, name: "Admin", email: "admin@barber.com", password: "1234", role: "admin"),
    User(id: 2, name: "Empleado", email: "emp@barber.com", password: "1234", role: "employee"),
    User(id: 3, name: "Cliente", email: "client@barber.com", password: "1234", role: "client"),
  ];

  Future<List<User>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_users);
  }

  Future<User?> createUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch,
      name: user.name,
      email: user.email,
      password: user.password,
      role: user.role,
    );

    _users.add(newUser);
    return newUser;
  }

  Future<bool> updateUser(int id, User user) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _users.indexWhere((u) => u.id == id);
    if (index == -1) return false;

    _users[index] = user;
    return true;
  }

  Future<bool> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users.removeWhere((u) => u.id == id);
    return true;
  }
}
