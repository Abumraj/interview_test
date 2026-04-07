import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/const.dart';
import 'package:interview/core/network/api_exceptions.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/screens/widgets/customTextfield.dart';
import 'package:interview/screens/widgets/custom_back_button.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/screens/widgets/verify_mail.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/toast_helper.dart';
import 'package:interview/utils/page_transitions.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _myKey = GlobalKey<FormState>();
  late TextEditingController textEmailEditingController;
  late TextEditingController textFirstNameEditingController;
  late TextEditingController textLastNameEditingController;
  late TextEditingController textPhoneNumberEditingController;
  late TextEditingController textPasswordEditingController;
  final combinedRegExpA = RegExp(r'[A-Z]');
  final combinedRegExpB = RegExp(r'[a-z]');
  final combinedRegExpC = RegExp(r'[0-9]');
  final combinedRegExpD = RegExp(r'[!@#$\^&*()~,?:{}|<>]');
  bool isObscure = true;
  bool isLoading = false;

  @override
  void initState() {
    textEmailEditingController = TextEditingController();
    textFirstNameEditingController = TextEditingController();
    textLastNameEditingController = TextEditingController();
    textPhoneNumberEditingController = TextEditingController();
    textPasswordEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textEmailEditingController.dispose();
    textFirstNameEditingController.dispose();
    textLastNameEditingController.dispose();
    textPhoneNumberEditingController.dispose();
    textPasswordEditingController.dispose();
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
              'assets/images/beech1.png',
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
          Form(
            key: _myKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: SafeArea(
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
                  const SizedBox(height: 120),
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
                              'Sign up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Register your account now',
                              style: TextStyle(
                                color: Color(0xFFB0C4DE),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomizedTextField(
                                    textTitle: "First Name",
                                    textEditingController:
                                        textFirstNameEditingController,
                                    hintTxt: "First Name",
                                    textInputAction: TextInputAction.next,
                                    inputFormat: [
                                      FilteringTextInputFormatter.deny(
                                        RegExp(r'[\s]'),
                                      ), // denies all whitespace
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r"[a-zA-Z'-]"),
                                      ), // allows all alphabets and apostrophy and hyphen
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your first name';
                                      } else if (value.length < 3) {
                                        return 'First name must be at least 3 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomizedTextField(
                                    textTitle: "Last name",
                                    textEditingController:
                                        textLastNameEditingController,
                                    hintTxt: "Enter Last Name",
                                    textInputAction: TextInputAction.next,
                                    inputFormat: [
                                      FilteringTextInputFormatter.deny(
                                        RegExp(r'[\s]'),
                                      ), // denies all whitespace
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r"[a-zA-Z'-]"),
                                      ), // allows all alphabets and apostrophy and hyphen
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your last name';
                                      } else if (value.length < 3) {
                                        return 'Last name must be at least 3 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 24),
                            // CustomizedTextField(
                            //   textTitle: "Phone Number",
                            //   textEditingController:
                            //       textPhoneNumberEditingController,
                            //   hintTxt: "Enter Phone Number",
                            //   textInputAction: TextInputAction.done,
                            //   keyboardType: TextInputType.phone,

                            //   validator: (value) {
                            //     return null;
                            //   },
                            // ),
                            const SizedBox(height: 24),
                            CustomizedTextField(
                              textTitle: "Email",
                              textEditingController: textEmailEditingController,
                              hintTxt: "Enter email",
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (p0) {
                                setState(() {});
                              },

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email cannot be empty";
                                }
                                return EmailValidator.validate(value)
                                    ? null
                                    : "Please enter a valid Email";
                              },
                            ),
                            const SizedBox(height: 24),
                            CustomizedTextField(
                              textTitle: "Password",
                              obsec: isObscure,
                              keyboardType: TextInputType.visiblePassword,
                              textEditingController:
                                  textPasswordEditingController,
                              hintTxt:
                                  "Passwords need to have at least 8 characters.",
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Password cannot be empty";
                                } else if (value.isNotEmpty &&
                                    value.length < 8) {
                                  // setState(() {passwordValue=value;});
                                  return 'Passwords need to have at least 8 characters';
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                              surffixWidget: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isObscure = !isObscure;
                                  });
                                },
                                child: Icon(
                                  isObscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.scaffoldDark,
                                ),
                              ),
                            ),
                            height8,
                            if (!(textPasswordEditingController.text.contains(
                                  combinedRegExpA,
                                ) &&
                                textPasswordEditingController.text.contains(
                                  combinedRegExpB,
                                ) &&
                                textPasswordEditingController.text.contains(
                                  combinedRegExpC,
                                ) &&
                                textPasswordEditingController.text.contains(
                                  combinedRegExpD,
                                )))
                              textPasswordEditingController.text.isNotEmpty
                                  ? ConfirmValidationWidget(
                                    passwordValue:
                                        textPasswordEditingController.text,
                                  )
                                  : const SizedBox.shrink(),

                            height30,
                            CustomButton(
                              onTap: () async {
                                if (!_myKey.currentState!.validate()) {
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                final email =
                                    textEmailEditingController.text
                                        .trim()
                                        .toLowerCase();

                                try {
                                  final phone =
                                      textPhoneNumberEditingController.text
                                          .trim();
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .registerAndRequestOtp(
                                        firstName:
                                            textFirstNameEditingController.text
                                                .trim(),
                                        lastName:
                                            textLastNameEditingController.text
                                                .trim(),
                                        email: email,
                                        phoneNumber:
                                            phone.isEmpty ? null : phone,
                                        password:
                                            textPasswordEditingController.text,
                                      );

                                  ToastHelper.showSuccess('Signup successful');
                                  if (!mounted) return;
                                  Navigator.of(context).pushReplacement(
                                    FadeScaleRoute(
                                      page: VerifyMail(email: email),
                                    ),
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
                              height: 50.h,
                              buttonText: "Sign Up",
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
          ),
        ],
      ),
    );
  }
}
