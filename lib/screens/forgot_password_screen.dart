import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/const.dart';
import 'package:interview/core/network/api_exceptions.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/screens/reset_password_screen.dart';
import 'package:interview/screens/widgets/customTextfield.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/toast_helper.dart';
import 'package:interview/utils/page_transitions.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        error: (_, __) {
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CustomProgressAppBar(
        showProgress: false,
        title: 'Forgot Password',
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                height24,
                Text(
                  'Reset your password',
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                height8,
                Text(
                  'Enter your email address. We will send an OTP to your inbox.',
                  style: TextStyle(
                    color: AppColors.whiteGreyColor,
                    fontSize: 14.sp,
                  ),
                ),
                height24,
                CustomizedTextField(
                  textTitle: 'Email Address',
                  textEditingController: _emailController,
                  hintTxt: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email cannot be empty';
                    }
                    if (!EmailValidator.validate(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                height30,
                CustomButton(
                  onTap: () async {
                    if (!_formKey.currentState!.validate()) return;

                    setState(() {
                      _isLoading = true;
                    });

                    final email = _emailController.text.trim().toLowerCase();

                    try {
                      await ref
                          .read(authControllerProvider.notifier)
                          .forgotPassword(email: email);
                      ToastHelper.showSuccess('OTP sent');
                      if (!mounted) return;
                      Navigator.of(context).push(
                        SlideRightRoute(
                          page: ResetPasswordScreen(email: email),
                        ),
                      );
                    } catch (e) {
                      final msg = e is ApiException ? e.message : e.toString();
                      ToastHelper.showError(msg);
                    } finally {
                      if (!mounted) return;
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  height: 50.h,
                  buttonText: 'Send OTP',
                  buttonColor: AppColors.lightBlue,
                  textColor: AppColors.whiteColor,
                  borderRadius: 30.r,
                  isLoading: _isLoading,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
