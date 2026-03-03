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

class EditPasswordScreen extends ConsumerStatefulWidget {
  const EditPasswordScreen({super.key});

  @override
  ConsumerState<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends ConsumerState<EditPasswordScreen> {
  final GlobalKey<FormState> _myKey = GlobalKey<FormState>();
  late TextEditingController textCurrentPasswordEditingController;
  late TextEditingController textConfirmPasswordEditingController;
  late TextEditingController textPasswordEditingController;
  bool isLoading = false;
  final combinedRegExpA = RegExp(r'[A-Z]');
  final combinedRegExpB = RegExp(r'[a-z]');
  final combinedRegExpC = RegExp(r'[0-9]');
  final combinedRegExpD = RegExp(r'[!@#$\^&*()~,?:{}|<>]');
  bool isObscure = true;
  bool isConfObscure = true;
  bool isCurrentObscure = true;

  @override
  void initState() {
    textCurrentPasswordEditingController = TextEditingController();
    textConfirmPasswordEditingController = TextEditingController();
    textPasswordEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textCurrentPasswordEditingController.dispose();
    textConfirmPasswordEditingController.dispose();
    textPasswordEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

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
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomProgressAppBar(
        // stepText: "Step 1 of 4",
        showProgress: false,
        title: 'Reset Password',
        // textColor: AppTheme.scaffoldDark,
        // Colors automatically use AppTheme
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h + keyboardInset),
          child: CustomButton(
            onTap: () async {
              if (!_myKey.currentState!.validate()) {
                return;
              }

              if (textPasswordEditingController.text !=
                  textConfirmPasswordEditingController.text) {
                return;
              }

              setState(() {
                isLoading = true;
              });

              try {
                await ref
                    .read(authControllerProvider.notifier)
                    .changePassword(
                      currentPassword:
                          textCurrentPasswordEditingController.text.trim(),
                      newPassword: textPasswordEditingController.text.trim(),
                      confirmPassword:
                          textConfirmPasswordEditingController.text.trim(),
                    );
                ToastHelper.showSuccess('Password changed');
                if (!mounted) return;
                Navigator.of(context).pop();
              } catch (e) {
                final msg = e is ApiException ? e.message : e.toString();
                ToastHelper.showError(msg);
              } finally {
                if (!mounted) return;
                setState(() {
                  isLoading = false;
                });
              }
            },
            height: 50.h,
            buttonText: "Save Changes",
            buttonColor: AppColors.lightBlue,
            textColor: AppColors.whiteColor,
            borderRadius: 30.r,
            isLoading: isLoading,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _myKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: SafeArea(
            child: Container(
              // margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomizedTextField(
                        textTitle: "Current Password",
                        textEditingController:
                            textCurrentPasswordEditingController,
                        hintTxt: "Enter Current Password",
                        textInputAction: TextInputAction.next,
                        obsec: isCurrentObscure,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Current Password';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        surffixWidget: GestureDetector(
                          onTap: () {
                            setState(() {
                              isCurrentObscure = !isCurrentObscure;
                            });
                          },
                          child: Icon(
                            isCurrentObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      height24,
                      CustomizedTextField(
                        textTitle: "Password",
                        obsec: isObscure,
                        keyboardType: TextInputType.visiblePassword,
                        textEditingController: textPasswordEditingController,
                        hintTxt:
                            "Passwords need to have at least 8 characters.",
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Password cannot be empty";
                          } else if (value.isNotEmpty && value.length < 8) {
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
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),

                      height24,
                      CustomizedTextField(
                        textTitle: "Confirm Password",
                        obsec: isConfObscure,
                        keyboardType: TextInputType.visiblePassword,
                        textEditingController:
                            textConfirmPasswordEditingController,
                        hintTxt:
                            "Passwords need to have at least 8 characters.",
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Confirm Password cannot be empty";
                          } else if (value.isNotEmpty && value.length < 8) {
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
                              isConfObscure = !isConfObscure;
                            });
                          },
                          child: Icon(
                            isConfObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.whiteColor,
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
                              passwordValue: textPasswordEditingController.text,
                            )
                            : const SizedBox.shrink(),
                      SizedBox(height: 120.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
