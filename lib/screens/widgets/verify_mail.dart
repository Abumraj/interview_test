import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/const.dart';
import 'package:interview/core/network/api_exceptions.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/screens/login_screen.dart';
import 'package:interview/screens/widgets/custom_back_button.dart';
import 'package:interview/screens/widgets/custom_pin_code.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/toast_helper.dart';
import 'package:interview/utils/page_transitions.dart';

class VerifyMail extends ConsumerStatefulWidget {
  final String email;
  final Duration resendCooldown;

  const VerifyMail({
    super.key,
    required this.email,
    this.resendCooldown = const Duration(seconds: 60),
  });

  @override
  ConsumerState<VerifyMail> createState() => _VerifyMailState();
}

class _VerifyMailState extends ConsumerState<VerifyMail>
    with WidgetsBindingObserver {
  String _otp = '';
  bool _isLoading = false;
  final FocusNode _pinFocusNode = FocusNode();

  Timer? _resendTimer;
  late int _secondsRemaining;

  bool get _canResend => _secondsRemaining <= 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _focusOtp();
      });
    }
  }

  void _focusOtp() {
    _pinFocusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = secs.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    _secondsRemaining = widget.resendCooldown.inSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 0) {
        timer.cancel();
        setState(() {});
        return;
      }
      setState(() {
        _secondsRemaining -= 1;
      });
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _secondsRemaining = widget.resendCooldown.inSeconds;
    _startResendCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusOtp();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinFocusNode.dispose();
    _resendTimer?.cancel();
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
      resizeToAvoidBottomInset: true,
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
                // SizedBox(height: 350.h),
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
                      child: GestureDetector(
                        onTap: _focusOtp,
                        child: ListView(
                          children: [
                            const Text(
                              'Verify your email address',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "We've sent a 6 digit code to this email address ${widget.email}.",
                              style: const TextStyle(
                                color: Color(0xFFB0C4DE),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Listener(
                              onPointerDown: (_) => _focusOtp(),
                              child: CustomPinCodeTextField(
                                context: context,
                                focusNode: _pinFocusNode,
                                onChanged: (p0) {
                                  _otp = p0;
                                },
                                onComplete: (p0) {
                                  _otp = p0;
                                },
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed:
                                    _canResend
                                        ? () async {
                                          try {
                                            await ref
                                                .read(
                                                  authControllerProvider
                                                      .notifier,
                                                )
                                                .requestOtp(
                                                  email: widget.email,
                                                );
                                            ToastHelper.showSuccess(
                                              'OTP resent',
                                            );
                                            _startResendCooldown();
                                          } catch (e) {
                                            final msg =
                                                e is ApiException
                                                    ? e.message
                                                    : e.toString();
                                            ToastHelper.showError(msg);
                                          }
                                        }
                                        : null,
                                child: Text(
                                  _canResend
                                      ? 'Resend OTP'
                                      : 'Resend OTP (${_formatSeconds(_secondsRemaining)})',
                                  style: TextStyle(
                                    color: AppColors.whiteGreyColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // const SizedBox(height: 24),
                            height45,
                            PrimaryButton(
                              label: 'Continue',
                              isLoading: _isLoading,
                              enabled: _otp.trim().length == 6,
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .verifyOtp(
                                        email: widget.email,
                                        otp: _otp,
                                      );

                                  ToastHelper.showSuccess('Email verified');
                                  if (!mounted) return;
                                  Navigator.of(context).pushAndRemoveUntil(
                                    FadeScaleRoute(page: const LoginScreen()),
                                    (route) => false,
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
                                    _isLoading = false;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
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
