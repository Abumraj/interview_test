import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview/const.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:rich_text_widget/rich_text_widget.dart';

class CustomeRichText extends StatelessWidget {
  final String text, text2, text3;
  final double? fontSize;
  const CustomeRichText({
    super.key,
    required this.text,
    required this.text2,
    required this.text3,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return RichTextWidget(
      Text(
        text,
        style: CustomTextStyle.headlineMedium.copyWith(
          fontSize: fontSize ?? 12.sp,
        ),
      ),
      richTexts: [
        BaseRichText(
          text2,
          style: CustomTextStyle.bodyMedium.copyWith(
            fontSize: fontSize ?? 12.sp,
          ),
          onTap: () => {},
        ),
        BaseRichText(
          text3,
          style: CustomTextStyle.bodyMedium.copyWith(
            fontSize: fontSize ?? 12.sp,
          ),
          onTap: () => {},
        ),
      ],
    );
  }
}

class DescriptionTextWidget extends StatefulWidget {
  final String text;
  final String title;
  final int txt_count;
  final double? fontSize;
  const DescriptionTextWidget({
    super.key,
    required this.text,
    required this.title,
    required this.txt_count,
    this.fontSize,
  });

  @override
  State<DescriptionTextWidget> createState() => _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  String? firstHalf;
  String? secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > widget.txt_count) {
      firstHalf = widget.text.substring(0, widget.txt_count);
      secondHalf = widget.text.substring(widget.txt_count, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return secondHalf!.isEmpty
        ? Text(
          firstHalf!,
          style: CustomTextStyle.bodySmall.copyWith(
            color: AppColors.whiteColor,
            fontSize: widget.fontSize ?? 14.sp,
          ),
        )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              flag ? (firstHalf! + "...") : (firstHalf! + secondHalf!),
              style: CustomTextStyle.bodySmall.copyWith(
                color: AppColors.whiteColor,
                fontSize: widget.fontSize ?? 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    flag ? "More" : "Less",
                    style: CustomTextStyle.bodySmall.copyWith(
                      color: AppColors.bottomNavBarHighlightColor,
                      fontSize: widget.fontSize ?? 14.sp,
                    ),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  flag = !flag;
                });
              },
            ),
          ],
        );
  }
}
