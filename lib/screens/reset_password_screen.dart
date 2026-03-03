import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/const.dart';
import 'package:interview/core/network/api_exceptions.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/screens/widgets/customTextfield.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/toast_helper.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _otpController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  final combinedRegExpA = RegExp(r'[A-Z]');
  final combinedRegExpB = RegExp(r'[a-z]');
  final combinedRegExpC = RegExp(r'[0-9]');
  final combinedRegExpD = RegExp(r'[!@#$\^&*()~,?:{}|<>]');

  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        title: 'Reset Password',
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(20.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  height24,
                  Text(
                    'Create a new password',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  height8,
                  Text(
                    'Enter the OTP sent to ${widget.email}, then choose a new password.',
                    style: TextStyle(
                      color: AppColors.whiteGreyColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  height24,
                  CustomizedTextField(
                    textTitle: 'OTP',
                    textEditingController: _otpController,
                    hintTxt: 'Enter OTP',
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'OTP is required';
                      }
                      return null;
                    },
                  ),
                  height24,
                  CustomizedTextField(
                    textTitle: 'New Password',
                    obsec: _isObscure,
                    textEditingController: _passwordController,
                    hintTxt: 'Enter new password',
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      }
                      if (value.length < 8) {
                        return 'Passwords need to have at least 8 characters';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                    surffixWidget: GestureDetector(
                      onTap: () => setState(() => _isObscure = !_isObscure),
                      child: Icon(
                        _isObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  height8,
                  if (!(_passwordController.text.contains(combinedRegExpA) &&
                      _passwordController.text.contains(combinedRegExpB) &&
                      _passwordController.text.contains(combinedRegExpC) &&
                      _passwordController.text.contains(combinedRegExpD)))
                    _passwordController.text.isNotEmpty
                        ? ConfirmValidationWidget(
                          passwordValue: _passwordController.text,
                        )
                        : const SizedBox.shrink(),
                  height24,
                  CustomizedTextField(
                    textTitle: 'Confirm Password',
                    obsec: _isConfirmObscure,
                    textEditingController: _confirmPasswordController,
                    hintTxt: 'Re-enter new password',
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm Password cannot be empty';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    surffixWidget: GestureDetector(
                      onTap:
                          () => setState(
                            () => _isConfirmObscure = !_isConfirmObscure,
                          ),
                      child: Icon(
                        _isConfirmObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  height30,
                  CustomButton(
                    onTap: () async {
                      if (!_formKey.currentState!.validate()) return;

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        await ref
                            .read(authControllerProvider.notifier)
                            .resetPassword(
                              email: widget.email,
                              otp: _otpController.text.trim(),
                              newPassword: _passwordController.text.trim(),
                            );

                        ToastHelper.showSuccess('Password reset successful');
                        if (!mounted) return;
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      } catch (e) {
                        final msg =
                            e is ApiException ? e.message : e.toString();
                        ToastHelper.showError(msg);
                      } finally {
                        if (!mounted) return;
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    height: 50.h,
                    buttonText: 'Reset password',
                    buttonColor: AppColors.lightBlue,
                    textColor: AppColors.whiteColor,
                    borderRadius: 30.r,
                    isLoading: _isLoading,
                  ),
                  height24,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
