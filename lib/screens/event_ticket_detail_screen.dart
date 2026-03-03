import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview/const.dart';
import 'package:interview/features/tickets/domain/ticket.dart';
import 'package:interview/helpers/date_extension.dart';
import 'package:interview/screens/dashboard.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/toast_helper.dart';
import 'package:interview/utils/page_transitions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

class EventTicketDetailScreen extends StatefulWidget {
  final Ticket? ticket;
  final String? bookingId;
  final String? title;
  final String? dateLine;
  final String? qrData;

  const EventTicketDetailScreen({
    super.key,
    required Ticket ticket,
    required dateLine,
  }) : ticket = ticket,
       bookingId = null,
       title = null,
       dateLine = null,
       qrData = null;

  const EventTicketDetailScreen.receipt({
    super.key,
    required this.bookingId,
    required this.title,
    this.dateLine,
    this.qrData,
  }) : ticket = null;

  @override
  State<EventTicketDetailScreen> createState() =>
      _EventTicketDetailScreenState();
}

class _EventTicketDetailScreenState extends State<EventTicketDetailScreen> {
  final GlobalKey _captureKey = GlobalKey();
  bool _isProcessing = false;

  bool get _isEventMode => widget.ticket != null;

  String _ticketCode() {
    final id =
        _isEventMode
            ? (widget.ticket!.bookingId ?? widget.ticket!.id)
            : (widget.bookingId ?? '');
    if (id.isEmpty) return '—';
    final suffix = id.length > 6 ? id.substring(id.length - 6) : id;
    return 'lwc-$suffix';
  }

  String _dateLine() {
    if (!_isEventMode) {
      return (widget.dateLine ?? '').trim();
    }
    final rawDate = widget.ticket!.date ?? widget.ticket!.eventDate;
    if (rawDate == null || rawDate.trim().isEmpty) return '';
    final formatted = formatDateTimeToLocal(rawDate);
    final time = (widget.ticket!.time ?? '').trim();
    if (time.isEmpty) return formatted;
    return '$formatted, at $time';
  }

  Future<Uint8List?> _capturePng() async {
    try {
      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<File?> _writeToTempFile(Uint8List pngBytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(pngBytes, flush: true);
    return file;
  }

  Future<void> _shareTicket() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final bytes = await _capturePng();
      if (bytes == null) {
        ToastHelper.showError('Unable to capture ticket');
        return;
      }
      final file = await _writeToTempFile(bytes);
      if (file == null) {
        ToastHelper.showError('Unable to prepare ticket for sharing');
        return;
      }

      final title =
          widget.ticket?.eventName ?? widget.ticket?.eventTitle ?? 'Ticket';
      await Share.shareXFiles([XFile(file.path)], text: title);
    } catch (e) {
      ToastHelper.showError(e.toString());
    } finally {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _downloadTicket() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final bytes = await _capturePng();
      if (bytes == null) {
        ToastHelper.showError('Unable to capture ticket');
        return;
      }

      // Save into app-private Documents directory (does not require runtime permissions).
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      ToastHelper.showSuccess('Ticket saved');

      // Optional: open system sheet so user can export to Downloads/Photos/Drive.
      final title =
          widget.ticket?.eventName ?? widget.ticket?.eventTitle ?? 'Ticket';
      await Share.shareXFiles([XFile(file.path)], text: title);
    } catch (e) {
      ToastHelper.showError(e.toString());
    } finally {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        _isEventMode
            ? (widget.ticket!.eventName ?? widget.ticket!.eventTitle ?? 'Event')
            : ((widget.title ?? '').trim().isEmpty ? 'Receipt' : widget.title!);

    final qr =
        _isEventMode
            ? (widget.ticket!.qrPayload ?? widget.ticket!.qr ?? '')
            : ((widget.qrData ?? widget.bookingId) ?? '');
    final dateLine = _dateLine();
    final code = _ticketCode();
    final cardRadius = 28.r;
    final seamCircleRadius = 18.r;
    const seamDividerHeight = 1.0;
    final topPad = 30.h;
    final pillHeight = 42.h;
    final topSectionHeight = topPad + pillHeight + topPad;
    final seamTop = topSectionHeight + (seamDividerHeight / 2);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomProgressAppBar(
        // stepText: "Step 1 of 4",
        showProgress: false,
        title: 'Ticket',
        // textColor: AppTheme.scaffoldDark,
        // Colors automatically use AppTheme
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              height35,
              RepaintBoundary(
                key: _captureKey,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.subcolor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(cardRadius),
                              topRight: Radius.circular(cardRadius),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: topPad,
                          ),
                          child: Center(
                            child: IntrinsicWidth(
                              child: Container(
                                height: pillHeight,
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColor,
                                  borderRadius: BorderRadius.circular(26.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  code,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: seamDividerHeight,
                          width: double.infinity,
                          color: Colors.white12,
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.subcolor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(cardRadius),
                              bottomRight: Radius.circular(cardRadius),
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 26.h),
                          child: Column(
                            children: [
                              if (dateLine.isNotEmpty)
                                Text(
                                  widget.dateLine ?? dateLine,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              SizedBox(height: 10.h),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: CustomTextStyle.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 26.h),
                              Container(
                                padding: EdgeInsets.all(18.r),
                                margin: EdgeInsets.symmetric(horizontal: 45.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child:
                                      qr.isEmpty
                                          ? const Center(
                                            child: Icon(
                                              Icons.qr_code_2,
                                              size: 120,
                                            ),
                                          )
                                          : QrImageView(
                                            data: qr,
                                            version: QrVersions.auto,
                                          ),
                                ),
                              ),
                              SizedBox(height: 50.h),
                              Text(
                                'Please present the QR code at the\nentrance',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: -seamCircleRadius,
                      top: seamTop - seamCircleRadius,
                      child: Container(
                        width: seamCircleRadius * 2,
                        height: seamCircleRadius * 2,
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -seamCircleRadius,
                      top: seamTop - seamCircleRadius,
                      child: Container(
                        width: seamCircleRadius * 2,
                        height: seamCircleRadius * 2,
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_isEventMode) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.lightBlue.withOpacity(0.8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        onPressed: _isProcessing ? null : _shareTicket,
                        icon: Icon(Icons.share, color: AppColors.lightBlue),
                        label: Text(
                          'Share',
                          style: TextStyle(
                            color: AppColors.lightBlue,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.lightBlue.withOpacity(0.8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        onPressed: _isProcessing ? null : _downloadTicket,
                        icon: Icon(
                          Icons.download_outlined,
                          color: AppColors.lightBlue,
                        ),
                        label: Text(
                          'Download Ticket',
                          style: TextStyle(
                            color: AppColors.lightBlue,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
              ] else
                SizedBox(height: 22.h),
              SizedBox(
                height: 55.h,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bottomNavBarHighlightColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      FadeScaleRoute(page: const Dashboard()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Return Home',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22.h),
            ],
          ),
        ),
      ),
    );
  }
}
