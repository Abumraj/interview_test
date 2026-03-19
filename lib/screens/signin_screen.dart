import 'dart:io';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:interview/const.dart';
import 'package:interview/core/network/api_exceptions.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/screens/dashboard.dart';
import 'package:interview/screens/login_screen.dart';
import 'package:interview/screens/signup_screen.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/page_transitions.dart';
import 'package:interview/utils/toast_helper.dart';
import 'package:interview/screens/widgets/verify_mail.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({super.key});

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen> {
  bool _googleLoading = false;
  bool _appleLoading = false;

  String _randomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List<String>.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
      growable: false,
    ).join();
  }

  String _sha256OfString(String input) {
    final bytes = input.codeUnits;
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _continueWithGoogle() async {
    if (_googleLoading) return;
    setState(() {
      _googleLoading = true;
    });
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseIdToken = await userCred.user?.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw const UnknownApiException(message: 'Failed to get Google token');
      }

      await ref
          .read(authControllerProvider.notifier)
          .loginWithGoogle(firebaseIdToken: firebaseIdToken);

      final user = ref.read(authControllerProvider).value?.user;
      final isVerified = user?.isVerified == true;
      if (!isVerified) {
        final email = user?.email?.trim();
        if (email == null || email.isEmpty) {
          throw const UnknownApiException(
            message: 'Email verification required but user email is missing',
          );
        }
        ToastHelper.showWarning(
          'Email not verified. Enter the OTP sent to your email.',
        );
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(FadeScaleRoute(page: VerifyMail(email: email)));
        return;
      }

      ToastHelper.showSuccess('Login successful');
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(FadeScaleRoute(page: const Dashboard()));
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      ToastHelper.showError(msg);
    } finally {
      if (!mounted) return;
      setState(() {
        _googleLoading = false;
      });
    }
  }

  Future<void> _continueWithApple() async {
    if (!Platform.isIOS) {
      ToastHelper.showWarning('Apple Sign-In is available on iOS only');
      return;
    }
    if (_appleLoading) return;
    setState(() {
      _appleLoading = true;
    });

    try {
      final rawNonce = _randomNonce();
      final nonce = _sha256OfString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final userCred = await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      );
      final firebaseIdToken = await userCred.user?.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw const UnknownApiException(message: 'Failed to get Apple token');
      }

      await ref
          .read(authControllerProvider.notifier)
          .loginWithGoogle(firebaseIdToken: firebaseIdToken);

      final user = ref.read(authControllerProvider).value?.user;
      final isVerified = user?.isVerified == true;
      if (!isVerified) {
        final email = user?.email?.trim();
        if (email == null || email.isEmpty) {
          throw const UnknownApiException(
            message: 'Email verification required but user email is missing',
          );
        }
        ToastHelper.showWarning(
          'Email not verified. Enter the OTP sent to your email.',
        );
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(FadeScaleRoute(page: VerifyMail(email: email)));
        return;
      }

      ToastHelper.showSuccess('Login successful');
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(FadeScaleRoute(page: const Dashboard()));
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      ToastHelper.showError(msg);
    } finally {
      if (!mounted) return;
      setState(() {
        _appleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF053C5E),
      body: Stack(
        children: [
          // Top Image
          // Bottom image (darker one)
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height / 2.5,
            child: Image.asset('assets/images/yacht.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height / 2.5,
            child: Image.asset(
              'assets/images/under_beech.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                height120,
                height55,
                height55,
                height55,
                height55,
                height55,
                Text(
                  "Experience the Water.",
                  style: CustomTextStyle.headlineLarge.copyWith(
                    color: AppColors.whiteColor,
                    fontSize: 24.sp,
                  ),
                ),
                Text(
                  "Elevate the Journey.",
                  style: CustomTextStyle.headlineLarge.copyWith(
                    color: AppColors.whiteColor,
                    fontSize: 24.sp,
                  ),
                ),
                height35,
                SlideInLeft(
                  duration: const Duration(milliseconds: 1200),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: CustomButton(
                      onTap: _continueWithGoogle,
                      buttonText: 'Continue with Google',
                      borderRadius: 30.r,
                      buttonColor: AppColors.inactiveButtonColor,
                      isLoading: _googleLoading,
                    ),
                  ),
                ),
                height28,
                if (Platform.isIOS) ...[
                  SlideInLeft(
                    duration: const Duration(milliseconds: 1200),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: CustomButton(
                        onTap: _continueWithApple,
                        buttonText: 'Continue with Apple',
                        borderRadius: 30.r,
                        buttonColor: AppColors.inactiveButtonColor,
                        isLoading: _appleLoading,
                      ),
                    ),
                  ),
                  height28,
                ],
                SlideInRight(
                  duration: const Duration(milliseconds: 1700),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: CustomButton(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(SlideRightRoute(page: const SignUpScreen()));
                      },
                      buttonText: 'Sign Up',
                      borderRadius: 30.r,
                      buttonColor: AppColors.lightBlue,
                    ),
                  ),
                ),
                height28,
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: CustomButton(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(SlideRightRoute(page: const LoginScreen()));
                    },
                    buttonText: 'Login',
                    borderRadius: 30.r,
                    buttonColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
