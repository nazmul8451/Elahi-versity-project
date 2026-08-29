import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../views/auth/login_contract.dart';

class LoginPresenter {
  final LoginViewContract _view;
  final AuthService _authService;

  LoginPresenter(this._view, {AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<void> login(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    // Client-side validation
    if (trimmedEmail.isEmpty) {
      _view.onLoginError('Please enter your email');
      return;
    }

    if (trimmedPassword.isEmpty) {
      _view.onLoginError('Please enter your password');
      return;
    }

    _view.showLoading();

    try {
      final UserModel user = await _authService.login(
        email: trimmedEmail,
        password: trimmedPassword,
      );
      _view.hideLoading();
      _view.onLoginSuccess(user);
    } on FirebaseAuthException catch (e) {
      _view.hideLoading();
      _view.onLoginError(_mapFirebaseAuthError(e));
    } catch (e) {
      _view.hideLoading();
      _view.onLoginError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email. Please register first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return e.message ?? 'Login failed. Please try again.';
    }
  }
}
