import '../models/user_model.dart';

class AuthService {
  /// Simulates an authentication network request
  Future<UserModel> login({required String email, required String password}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'user@test.com' && password == '123456') {
      return UserModel(
        id: 'user_101',
        email: email,
        name: 'Demo User',
      );
    } else {
      throw Exception('Invalid credentials. Use user@test.com and 123456');
    }
  }
}
