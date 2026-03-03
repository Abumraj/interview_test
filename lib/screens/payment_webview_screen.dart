import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:interview/const.dart';
import 'package:interview/features/payments/presentation/payments_controller.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String initialUrl;
  final String callbackUrlPrefix;
  final String txRef;

  const PaymentWebViewScreen({
    super.key,
    required this.initialUrl,
    required this.callbackUrlPrefix,
    required this.txRef,
  });

  @override
  ConsumerState<PaymentWebViewScreen> createState() =>
      _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) {
                if (!mounted) return;
                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (_) {
                if (!mounted) return;
                setState(() {
                  _isLoading = false;
                });
              },

              onNavigationRequest: (request) async {
                final url = request.url;
                if (url.startsWith(widget.callbackUrlPrefix)) {
                  if (_isVerifying) {
                    return NavigationDecision.prevent;
                  }
                  _isVerifying = true;
                  if (mounted) {
                    setState(() {
                      _isLoading = true;
                    });
                  }

                  final uri = Uri.tryParse(url);
                  final transactionId = uri?.queryParameters['transaction_id'];

                  try {
                    final verified = await ref
                        .read(paymentsControllerProvider.notifier)
                        .verify(
                          txRef: widget.txRef,
                          transactionId: transactionId,
                        );
                    if (!mounted) return NavigationDecision.prevent;
                    Navigator.of(context).pop(verified);
                  } catch (_) {
                    if (!mounted) return NavigationDecision.prevent;
                    Navigator.of(context).pop(false);
                  }
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: SpinKitFadingCircle(size: 30, color: AppColors.whiteColor),
            ),
        ],
      ),
    );
  }
}
