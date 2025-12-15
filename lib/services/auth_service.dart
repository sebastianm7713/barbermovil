import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api.dart';
import '../models/user.dart';

class AuthService {
  User? currentUser;
  String? token;

  // LOGIN
  Future<User?> login(String email, String password) async {
    final url = Uri.parse('${Api.baseUrl}/auth/login');

    final response = await http.post(
      url,
      body: {
        "email": email,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      token = data["token"];
      currentUser = User.fromJson(data["user"]);

      return currentUser;
    } else {
      return null;
    }
  }

  // LOGOUT
  void logout() {
    currentUser = null;
    token = null;
  }
}
