import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/const.dart';
import 'package:interview/core/network/api_exceptions.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/features/profile/presentation/profile_controller.dart';
import 'package:interview/screens/widgets/customTextfield.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/utils/toast_helper.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final GlobalKey<FormState> _myKey = GlobalKey<FormState>();
  late TextEditingController textEmailEditingController;
  late TextEditingController textFirstNameEditingController;
  late TextEditingController textLastNameEditingController;
  late TextEditingController textPhoneNumberEditingController;
  bool isLoading = false;

  void _prefillFromAuthUserIfEmpty() {
    final user = ref.read(authControllerProvider).value?.user;
    if (user == null) return;

    if (textFirstNameEditingController.text.trim().isEmpty) {
      textFirstNameEditingController.text = (user.firstName ?? '').trim();
    }
    if (textLastNameEditingController.text.trim().isEmpty) {
      textLastNameEditingController.text = (user.lastName ?? '').trim();
    }
    if (textEmailEditingController.text.trim().isEmpty) {
      textEmailEditingController.text = (user.email ?? '').trim();
    }
    if (textPhoneNumberEditingController.text.trim().isEmpty) {
      textPhoneNumberEditingController.text = (user.phoneNumber ?? '').trim();
    }
  }

  @override
  void initState() {
    textEmailEditingController = TextEditingController();
    textFirstNameEditingController = TextEditingController();
    textLastNameEditingController = TextEditingController();
    textPhoneNumberEditingController = TextEditingController();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFromAuthUserIfEmpty();
      setState(() {});
    });
  }

  @override
  void dispose() {
    textEmailEditingController.dispose();
    textFirstNameEditingController.dispose();
    textLastNameEditingController.dispose();
    textPhoneNumberEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    ref.listen(profileControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (isLoading) {
            setState(() {
              isLoading = false;
            });
            ToastHelper.showSuccess('Profile updated');
          }
        },
        error: (err, _) {
          if (isLoading) {
            setState(() {
              isLoading = false;
            });
            final msg = err is ApiException ? err.message : err.toString();
            ToastHelper.showError(msg);
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomProgressAppBar(
        // stepText: "Step 1 of 4",
        showProgress: false,
        title: 'Edit Profile',
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
              if (isLoading) return;
              if (!(_myKey.currentState?.validate() ?? false)) {
                return;
              }

              setState(() {
                isLoading = true;
              });

              try {
                await ref
                    .read(profileControllerProvider.notifier)
                    .updateProfile(
                      userId:
                          ref.read(authControllerProvider).value?.user?.id ??
                          '',
                      firstName: textFirstNameEditingController.text.trim(),
                      lastName: textLastNameEditingController.text.trim(),
                      email: textEmailEditingController.text.trim(),
                      phoneNumber: textPhoneNumberEditingController.text.trim(),
                    );

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
                              hintTxt: "Last Name",
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
                        textTitle: "Phone Number",
                        textEditingController: textPhoneNumberEditingController,
                        hintTxt: "Enter Phone Number",
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
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
