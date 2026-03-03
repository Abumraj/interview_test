import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:interview/const.dart';
import 'package:interview/features/history/domain/purchase_details.dart';
import 'package:interview/screens/dashboard.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/screens/widgets/detail_row.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/money_formatter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:interview/utils/page_transitions.dart';

class OrderTicketDetailScreen extends StatelessWidget {
  final String bookingId;
  final PurchaseDetails details;

  const OrderTicketDetailScreen({
    super.key,
    required this.bookingId,
    required this.details,
  });

  String _codeFromId(String id) {
    if (id.isEmpty) return '—';
    final suffix = id.length > 4 ? id.substring(id.length - 4) : id;
    return 'lwc-$suffix';
  }

  String _formatDateLine(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '';
    final dt = DateTime.tryParse(v);
    if (dt == null) return v;
    final local = dt.toLocal();
    final date = DateFormat('MMM d, y').format(local);
    final time = DateFormat('h:mm a').format(local);
    return '$date - $time';
  }

  @override
  Widget build(BuildContext context) {
    final amountLabel = MoneyFormatter.ngn(
      details.amount ?? 0,
      decimalDigits: 2,
    );
    final title =
        details.leisureType.trim().isEmpty
            ? 'Service'
            : details.leisureType.trim();

    final dateLine = _formatDateLine(details.dateTime);

    final txType =
        (details.transactionType ?? '').trim().isEmpty
            ? 'Service'
            : details.transactionType!.trim();

    final txId =
        (details.transactionId ?? '').trim().isEmpty
            ? bookingId
            : details.transactionId!.trim();
    final qrPayload = details.qrPayload;
    final code = _codeFromId(txId);

    return Scaffold(
      backgroundColor: AppColors.subcolor,
      appBar: const CustomProgressAppBar(
        showProgress: false,
        title: 'Ticket',
        backgroundColor: AppColors.subcolor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.6)),
                ),
                padding: EdgeInsets.all(12.w),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              height12,
              Text(
                amountLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6.h),
              if (dateLine.isNotEmpty)
                Text(
                  dateLine,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              SizedBox(height: 20.h),
              Container(
                width: MediaQuery.of(context).size.width / 1.5,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: QrImageView(
                    data: qrPayload.toString(),
                    version: QrVersions.auto,
                    gapless: false,
                  ),
                ),
              ),
              SizedBox(height: 26.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Details',
                  style: CustomTextStyle.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Divider(color: Colors.white.withOpacity(0.12), height: 1),
              SizedBox(height: 16.h),
              DetailRow(label: 'Transaction type:', value: txType),
              SizedBox(height: 16.h),
              DetailRow(label: 'Transaction ID:', value: txId),
              SizedBox(height: 16.h),
              DetailRow(label: 'Code:', value: code),
              const Spacer(),
              PrimaryButton(
                label: 'Return Home',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    FadeScaleRoute(page: const Dashboard()),
                    (route) => false,
                  );
                },
              ),
              height20,
            ],
          ),
        ),
      ),
    );
  }
}
