import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/const.dart';
import 'package:interview/core/network/api_exceptions.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/screens/forgot_password_screen.dart';
import 'package:interview/screens/dashboard.dart';
import 'package:interview/screens/widgets/verify_mail.dart';
import 'package:interview/screens/widgets/customTextfield.dart';
import 'package:interview/screens/widgets/custom_back_button.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/toast_helper.dart';
import 'package:interview/utils/page_transitions.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isConfObscure = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (isLoading) {
            setState(() {
              isLoading = false;
            });
          }
        },
        error: (_, __) {
          if (isLoading) {
            setState(() {
              isLoading = false;
            });
          }
        },
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            // child: SvgPicture.asset(
            //   "assets/images/beach.svg",
            //   fit: BoxFit.cover,
            //   errorBuilder: (context, error, stackTrace) {
            //     print(error);
            //     return Container(color: const Color(0xFF4A9B9B));
            //   },
            // ),
            child: Image.asset(
              'assets/images/beech.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFF4A9B9B));
              },
            ),
            //   errorBuilder: (context, error, stackTrace) {
            //     return Container(color: const Color(0xFF4A9B9B));
            //   },
            // ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Back Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomBackButton(
                      onPressed: () {
                        // Handle back navigation
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                // SizedBox(height: 280.h),
                Spacer(),
                // Sign Up Form Card
                Expanded(
                  child: Container(
                    // margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.navBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32.r),
                        topRight: Radius.circular(32.r),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: ListView(
                        children: [
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Login back to your LWC account',
                            style: TextStyle(
                              color: Color(0xFFB0C4DE),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // const SizedBox(height: 24),
                          CustomizedTextField(
                            textTitle: "Email Address",
                            textEditingController: emailCtrl,
                            hintTxt: "Enter your email address",
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            inputFormat: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email address';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          height24,
                          CustomizedTextField(
                            textTitle: "Password",
                            textEditingController: passCtrl,
                            hintTxt: "Enter your password",
                            obsec: isConfObscure,

                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            surffixWidget: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isConfObscure = !isConfObscure;
                                });
                              },
                              child: Icon(
                                isConfObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.scaffoldDark,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  SlideRightRoute(
                                    page: const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: AppColors.whiteGreyColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          height28,
                          CustomButton(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });

                              try {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .login(
                                      email:
                                          emailCtrl.text.trim().toLowerCase(),
                                      password: passCtrl.text,
                                    );

                                final user =
                                    ref
                                        .read(authControllerProvider)
                                        .value
                                        ?.user;
                                print(user?.isVerified);
                                final isVerified = user?.isVerified == true;

                                if (!isVerified) {
                                  final email = user?.email?.trim();
                                  if (email == null || email.isEmpty) {
                                    throw const UnknownApiException(
                                      message:
                                          'Email verification required but user email is missing',
                                    );
                                  }
                                  ToastHelper.showWarning(
                                    'Email not verified. Enter the OTP sent to your email.',
                                  );
                                  if (!mounted) return;
                                  Navigator.of(context).pushReplacement(
                                    FadeScaleRoute(
                                      page: VerifyMail(email: email),
                                    ),
                                  );
                                  return;
                                }

                                ToastHelper.showSuccess('Login successful');
                                if (!mounted) return;
                                Navigator.of(context).pushReplacement(
                                  FadeScaleRoute(page: const Dashboard()),
                                );
                              } catch (e) {
                                final msg =
                                    e is ApiException
                                        ? e.message
                                        : e.toString();
                                ToastHelper.showError(msg);
                              } finally {
                                if (!mounted) return;
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            height: 55.h,
                            buttonText: "Log In",
                            buttonColor: AppColors.lightBlue,
                            textColor: AppColors.whiteColor,
                            borderRadius: 30.r,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // const SizedBox(height: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
