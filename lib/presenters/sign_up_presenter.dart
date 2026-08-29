import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../views/auth/sign_up_contract.dart';

class SignUpPresenter {
  final SignUpViewContract _view;
  final AuthService _authService;

  SignUpPresenter(this._view, {AuthService? authService})
      : _authService = authService ?? AuthService();

  static final RegExp _emailRegExp =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool agreedToTerms,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    // Client-side validations
    if (trimmedName.isEmpty) {
      _view.onSignUpError('Please enter your full name');
      return;
    }

    if (trimmedEmail.isEmpty) {
      _view.onSignUpError('Please enter your email');
      return;
    }

    if (!_emailRegExp.hasMatch(trimmedEmail)) {
      _view.onSignUpError('Please enter a valid email address');
      return;
    }

    if (password.isEmpty) {
      _view.onSignUpError('Please enter a password');
      return;
    }

    if (password.length < 6) {
      _view.onSignUpError('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      _view.onSignUpError('Passwords do not match');
      return;
    }

    if (!agreedToTerms) {
      _view.onSignUpError('Please agree to the Terms & Privacy Policy');
      return;
    }

    _view.showLoading();

    try {
      final UserModel user = await _authService.register(
        name: trimmedName,
        email: trimmedEmail,
        password: password,
      );
      _view.hideLoading();
      _view.onSignUpSuccess(user);
    } on FirebaseAuthException catch (e) {
      _view.hideLoading();
      _view.onSignUpError(_mapFirebaseAuthError(e));
    } catch (e) {
      _view.hideLoading();
      _view.onSignUpError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email address is already registered. Please sign in or use a different email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Console.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      default:
        return e.message ?? 'Registration failed. Please try again.';
    }
  }
}
