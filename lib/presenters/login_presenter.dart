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
    } catch (e) {
      _view.hideLoading();
      _view.onLoginError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
