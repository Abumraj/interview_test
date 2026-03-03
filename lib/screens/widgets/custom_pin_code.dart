import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview/const.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// ignore: must_be_immutable
class CustomPinCodeTextField extends StatelessWidget {
  CustomPinCodeTextField({
    super.key,
    required this.context,
    required this.onChanged,
    this.alignment,
    this.controller,
    this.textStyle,
    this.hintStyle,
    this.validator,
    this.focusNode,
    required this.onComplete,
  });

  final Alignment? alignment;
  final Function(String) onComplete;

  final BuildContext context;

  final TextEditingController? controller;

  final TextStyle? textStyle;

  final TextStyle? hintStyle;

  Function(String) onChanged;

  final FormFieldValidator<String>? validator;

  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
          alignment: alignment ?? Alignment.center,
          child: pinCodeTextFieldWidget,
        )
        : pinCodeTextFieldWidget;
  }

  Widget get pinCodeTextFieldWidget => PinCodeTextField(
    appContext: context,
    controller: controller,
    focusNode: focusNode,
    length: 6,
    autoFocus: true,
    keyboardType: TextInputType.number,
    textStyle: textStyle ?? CustomTextStyle.bodyMedium,
    hintStyle: hintStyle ?? CustomTextStyle.bodySmall,
    onCompleted: onComplete,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    enableActiveFill: true,
    pinTheme: PinTheme(
      fieldHeight: 45.h,
      fieldWidth: 45.h,
      shape: PinCodeFieldShape.box,
      inactiveFillColor: AppColors.subCardcolor,
      activeFillColor: AppColors.bottomNavBarHighlightColor,
      selectedFillColor: AppColors.bottomNavBarHighlightColor,
      inactiveColor: AppColors.subCardcolor,
      activeColor: AppColors.bottomNavBarHighlightColor,
      selectedColor: AppColors.bottomNavBarHighlightColor,
    ),
    onChanged: (value) => onChanged(value),
    validator: validator,
  );
}
