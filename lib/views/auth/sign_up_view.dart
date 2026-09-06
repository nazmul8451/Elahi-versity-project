import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/user_model.dart';
import '../../presenters/sign_up_presenter.dart';
import 'login_view.dart';
import 'sign_up_contract.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> implements SignUpViewContract {
  late final SignUpPresenter _presenter;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = SignUpPresenter(this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- SignUpViewContract Implementation ---
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void onSignUpSuccess(UserModel user) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully! Please sign in.'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  void onSignUpError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      _presenter.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        agreedToTerms: _agreedToTerms,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20.r),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon / Logo
                  Center(
                    child: Container(
                      width: 72.r,
                      height: 72.r,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16.r,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                        size: 36.r,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Header Titles
                  Text(
                    AppStrings.signUpTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    AppStrings.signUpSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Full Name Field
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: AppStrings.fullName,
                      hintText: AppStrings.fullNameHint,
                      prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20.r),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),

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
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    textInputAction: TextInputAction.next,
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
                  SizedBox(height: 14.h),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmPasswordObscured,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignUp(),
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: AppStrings.confirmPassword,
                      hintText: AppStrings.confirmPasswordHint,
                      prefixIcon: Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 20.r),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20.r,
                        ),
                        onPressed: () {
                          setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Terms & Conditions Checkbox
                  Row(
                    children: [
                      SizedBox(
                        height: 24.r,
                        width: 24.r,
                        child: Checkbox(
                          value: _agreedToTerms,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                          onChanged: (val) {
                            setState(() => _agreedToTerms = val ?? false);
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          AppStrings.agreeTerms,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Global Custom Button for Sign Up
                  CustomButton(
                    text: AppStrings.signUpBtn,
                    isLoading: _isLoading,
                    onPressed: _handleSignUp,
                  ),
                  SizedBox(height: 20.h),

                  // Already have an account? Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                      ),
                      TextButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginView()),
                            );
                          }
                        },
                        child: Text(
                          AppStrings.signInNow,
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
}
