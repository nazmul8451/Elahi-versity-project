import '../../models/user_model.dart';

/// Contract defining the UI actions the Presenter can trigger on the View
abstract class LoginViewContract {
  void showLoading();
  void hideLoading();
  void onLoginSuccess(UserModel user);
  void onLoginError(String message);
}
