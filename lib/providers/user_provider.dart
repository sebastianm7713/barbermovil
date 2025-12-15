import 'package:flutter/material.dart';
import '../models/user.dart';
import '../mock/mock_users_admin.dart';

class UserProvider extends ChangeNotifier {
  final List<User> _users = [...adminUsers];

  List<User> get users => _users;

  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }
}
