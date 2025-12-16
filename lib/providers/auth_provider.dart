import 'package:flutter/material.dart';
import '../models/user.dart';
import '../mock/mock_users.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;

  /// 👇 copia mutable de los mocks
  final List<User> _users = List.from(mockUsers);

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  /// 🔐 LOGIN REAL
  User? login(String email, String password) {
    try {
      final user = _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );

      _user = user;
      notifyListeners();
      return user;
    } catch (e) {
      return null;
    }
  }

  /// 📝 REGISTER REAL
  bool register(User newUser) {
    final exists = _users.any((u) => u.email == newUser.email);
    if (exists) return false;

    _users.add(newUser);
    notifyListeners();
    return true;
  }

  /// 🚪 LOGOUT
  void logout() {
    _user = null;
    notifyListeners();
  }
}
