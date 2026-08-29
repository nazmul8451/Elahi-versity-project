import '../../models/user_model.dart';

/// Contract defining the UI actions the SignUpPresenter can trigger on the SignUpView
abstract class SignUpViewContract {
  void showLoading();
  void hideLoading();
  void onSignUpSuccess(UserModel user);
  void onSignUpError(String message);
}
