import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/user_model.dart';
import '../../presenters/login_presenter.dart';
import '../main_nav_view.dart';
import 'login_contract.dart';
import 'sign_up_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> implements LoginViewContract {
  late final LoginPresenter _presenter;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = LoginPresenter(this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LoginViewContract Implementation ---
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void onLoginSuccess(UserModel user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppStrings.loginSuccess} Welcome ${user.name}!'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainNavView(user: user)),
    );
  }

  @override
  void onLoginError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _presenter.login(_emailController.text, _passwordController.text);
    }
  }

  void _fillDemoAccount() {
    setState(() {
      _emailController.text = 'builder@pcbuilder.com';
      _passwordController.text = '123456';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo credentials loaded!'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon / Logo
                  Center(
                    child: Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 20.r,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.memory_rounded,
                        color: Colors.white,
                        size: 44.r,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Header Titles
                  Text(
                    AppStrings.loginTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    AppStrings.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: AppStrings.email,
                      hintText: AppStrings.emailHint,
                      prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.primary, size: 20.r),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      hintText: AppStrings.passwordHint,
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20.r),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20.r,
                        ),
                        onPressed: () {
                          setState(() => _isPasswordObscured = !_isPasswordObscured);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Remember Me & Forgot Password Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 24.r,
                            width: 24.r,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                              onChanged: (val) {
                                setState(() => _rememberMe = val ?? false);
                              },
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Remember me',
                            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset link sent to your email!')),
                          );
                        },
                        child: Text(
                          AppStrings.forgotPassword,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Demo Credentials Quick Fill Chip
                  Center(
                    child: TextButton.icon(
                      onPressed: _fillDemoAccount,
                      icon: Icon(Icons.bolt_rounded, size: 16.r, color: AppColors.primary),
                      label: Text(
                        'Autofill Demo Account',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primarySurface,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Login Button
                  CustomButton(
                    text: AppStrings.loginBtn,
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  SizedBox(height: 20.h),

                  // Or Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton(
                        icon: Icons.g_mobiledata_rounded,
                        iconSize: 34.r,
                        onTap: () {
                          _presenter.login('builder@pcbuilder.com', '123456');
                        },
                      ),
                      SizedBox(width: 16.w),
                      _socialButton(
                        icon: Icons.apple_rounded,
                        iconSize: 26.r,
                        onTap: () {
                          _presenter.login('builder@pcbuilder.com', '123456');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Don't have an account? Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpView()),
                          );
                        },
                        child: Text(
                          AppStrings.signUpNow,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, required double iconSize, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 54.r,
        height: 54.r,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: iconSize, color: AppColors.textPrimary),
      ),
    );
  }
}
