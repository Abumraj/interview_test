import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview/const.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';

class CustomizedTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? labeltxt;
  final String? hintTxt;
  final bool? obsec;
  final Widget? surffixWidget;
  final Function(String)? onChanged;
  final bool? readOnly;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  final BoxConstraints? suffixIconConstraints;
  final int? maxLines;
  final int? maxLength;
  final String? suffixText;
  final String? textTitle;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormat;
  const CustomizedTextField({
    super.key,
    this.maxLines,
    this.textEditingController,
    this.keyboardType,
    this.textInputAction,
    this.labeltxt,
    this.hintTxt,
    this.obsec,
    this.surffixWidget,
    this.inputFormat,
    this.readOnly,
    this.onChanged,
    this.validator,
    this.onTap,
    this.suffixIconConstraints,
    this.maxLength,
    this.suffixText,
    this.prefixIcon,
    this.contentPadding,
    this.prefixIconConstraints,
    this.textTitle,
  });

  @override
  State<CustomizedTextField> createState() => _CustomizedTextFieldState();
}

class _CustomizedTextFieldState extends State<CustomizedTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.textTitle == null
            ? const SizedBox.shrink()
            : Text(
              widget.textTitle ?? "",
              style: CustomTextStyle.bodySmall.copyWith(
                fontSize: 16.sp,
                color: AppColors.whiteColor,
              ),
            ),
        widget.textTitle == null ? const SizedBox.shrink() : height8,
        TextFormField(
          autofocus: false,
          obscureText: widget.obsec ?? false,
          textCapitalization:
              widget.keyboardType == TextInputType.emailAddress
                  ? TextCapitalization.none
                  : TextCapitalization.sentences,
          controller: widget.textEditingController,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          textAlignVertical: TextAlignVertical.center,
          readOnly: widget.readOnly ?? false,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          inputFormatters: widget.inputFormat ?? [],
          onChanged: widget.onChanged,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines ?? 1,
          validator:
              widget.validator ??
              (value) {
                if (value!.isEmpty) {
                  return "Fill empty field";
                } else {
                  return null;
                }
              },
          style: CustomTextStyle.caption2.copyWith(
            color: AppColors.whiteColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: widget.hintTxt,
            isDense: true,
            suffixText: widget.suffixText,
            contentPadding: widget.contentPadding,
            suffixIconConstraints: widget.suffixIconConstraints,
            prefixIconConstraints: widget.prefixIconConstraints,
            suffixIcon: widget.surffixWidget ?? const SizedBox.shrink(),
            fillColor: AppColors.subCardcolor,
            prefixIcon: widget.prefixIcon,
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary, width: 0.5.w),
              borderRadius: BorderRadius.circular(14.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary, width: 0.5.w),
              borderRadius: BorderRadius.circular(14.r),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.error, width: 0.5.w),
              borderRadius: BorderRadius.circular(14.r),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.textFieldColor2,
                width: 0.5.w,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary, width: 0.5.w),
              borderRadius: BorderRadius.circular(14.r),
            ),
            hintStyle: CustomTextStyle.bodyLarge.copyWith(
              color: AppTheme.textFieldColor2,
              fontSize: 16.sp,
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
      ],
    );
  }
}

class ConfirmValidationWidget extends StatelessWidget {
  final String passwordValue;
  const ConfirmValidationWidget({super.key, required this.passwordValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),

        /// [default requirements]
        /// `1 Upper case` requirement
        _PassCheckRequirements(
          passCheck: passwordValue.contains(RegExp(r'[A-Z]')),
          requirementText: "Uppercase [A-Z]",
        ),

        /// `1 lowercase` requirement
        _PassCheckRequirements(
          passCheck: passwordValue.contains(RegExp(r'[a-z]')),
          requirementText: "Lowercase [a-z]",
        ),

        /// `1 numeric value` requirement
        _PassCheckRequirements(
          passCheck: passwordValue.contains(RegExp(r'[0-9]')),
          requirementText: "Numeric value [0-9]",
        ),

        /// `1 special character` requirement
        _PassCheckRequirements(
          passCheck: passwordValue.contains(RegExp(r'[!@#$\^&*()~,?:{}|<>]')),
          requirementText: "Special character [#, \$, @, *, etc..]",
        ),

        /// `6 character length` requirement
        _PassCheckRequirements(
          passCheck: passwordValue.length >= 8,
          requirementText: "8 Characters minimum",
        ),
      ],
    );
  }
}

class _PassCheckRequirements extends StatelessWidget {
  /// a `bool` value as check [required] field in case you want to `modify` the package
  final bool? passCheck;

  /// requirement text [required] field in case you want to `modify` the package
  final String? requirementText;

  /// IconData when requirement is completed
  final IconData? activeIcon;

  /// IconData when requirement is not completed/inActive
  final IconData? inActiveIcon;

  /// inActive color
  final Color? inActiveColor;

  /// Active color
  final Color? activeColor;

  const _PassCheckRequirements({
    @required this.passCheck,

    /// [required parameters] in case you want to modify the package
    @required this.requirementText,

    /// [required parameters] in case you want to modify the package
    /// [default] value of in-active IconData
    this.inActiveIcon = Icons.cancel_outlined,

    /// [default] value of active IconData
    this.activeIcon = Icons.check_circle_rounded,

    /// [default] color of in-active field
    this.inActiveColor = AppColors.error,

    /// [default] color of active field
    this.activeColor = AppColors.lightBlue,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          /// requirement IconData based on check!
          passCheck!
              ? Icon(Icons.check_circle_rounded, color: activeColor)
              : Icon(Icons.check_circle_outline_rounded, color: inActiveColor),
          const SizedBox(width: 8.0),

          /// requirement text
          Text(
            requirementText!,
            style: TextStyle(
              color: passCheck! ? activeColor : inActiveColor,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
