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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({super.key});

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen> {
  bool _googleLoading = false;
  bool _appleLoading = false;

  static const String _googleSvg =
      '<svg width="48" height="48" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">'
      '<path fill="#EA4335" d="M24 9.5c3.54 0 6.36 1.54 8.28 3.28l6.14-6.14C34.76 3.1 29.82 1 24 1 14.61 1 6.53 6.38 2.56 14.22l7.18 5.57C11.5 13.62 17.23 9.5 24 9.5z"/>'
      '<path fill="#4285F4" d="M46.5 24.5c0-1.69-.15-2.95-.47-4.25H24v8.06h12.88c-.26 2.03-1.69 5.09-4.87 7.14l7.48 5.8C44.33 37.15 46.5 31.4 46.5 24.5z"/>'
      '<path fill="#FBBC05" d="M9.74 28.12c-.47-1.4-.74-2.89-.74-4.42s.27-3.02.72-4.42l-7.18-5.57C1.55 16.1 1 19.02 1 23.7c0 4.68.55 7.6 1.54 10.0l7.2-5.58z"/>'
      '<path fill="#34A853" d="M24 46c5.82 0 10.71-1.92 14.28-5.23l-7.48-5.8c-2.0 1.4-4.7 2.38-6.8 2.38-6.77 0-12.5-4.12-14.26-9.86l-7.2 5.58C6.53 40.62 14.61 46 24 46z"/>'
      '</svg>';

  static const String _appleSvg =
      '<svg width="48" height="48" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">'
      '<path fill="#FFFFFF" d="M16.365 1.43c0 1.14-.42 2.205-1.255 3.127-.84.934-2.215 1.65-3.35 1.56-.14-1.09.46-2.25 1.265-3.14.885-.97 2.34-1.67 3.34-1.55z"/>'
      '<path fill="#FFFFFF" d="M20.515 17.13c-.62 1.43-.92 2.07-1.72 3.33-1.12 1.73-2.7 3.88-4.67 3.9-1.76.02-2.21-1.14-4.59-1.14-2.38 0-2.87 1.12-4.62 1.16-1.97.04-3.48-1.94-4.6-3.66-3.13-4.83-3.46-10.5-1.53-13.46 1.37-2.1 3.55-3.33 5.6-3.33 1.76 0 3.22 1.18 4.58 1.18 1.31 0 3.35-1.46 5.64-1.24.96.04 3.65.39 5.38 2.95-.14.09-3.21 1.87-3.18 5.57.03 4.42 3.88 5.89 3.91 5.91-.01.04-.06.22-.2.53z"/>'
      '</svg>';

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

      final identityToken = appleCredential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw const UnknownApiException(
          message: 'Apple Sign-In failed: missing identity token',
        );
      }

      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: identityToken, rawNonce: rawNonce);

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
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return;
      }
      ToastHelper.showError(e.message);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        ToastHelper.showError(
          'Apple Sign-In is not configured correctly. '
          'Enable Apple provider in Firebase Auth and ensure the iOS app has Sign In with Apple capability '
          'and uses bundle id com.purplegate.lwc.',
        );
      } else {
        ToastHelper.showError(e.message ?? e.toString());
      }
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
                      leading: SvgPicture.string(
                        _googleSvg,
                        width: 18.w,
                        height: 18.w,
                      ),
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
                        leading: SvgPicture.string(
                          _appleSvg,
                          width: 18.w,
                          height: 18.w,
                        ),
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
