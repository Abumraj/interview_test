import 'payments_api.dart';

class PaymentInit {
  final String checkoutUrl;
  final String txRef;
  final bool completed;

  const PaymentInit({
    required this.checkoutUrl,
    required this.txRef,
    required this.completed,
  });
}

class PaymentsRepository {
  PaymentsRepository({required PaymentsApi api}) : _api = api;

  final PaymentsApi _api;

  String? _extractUrl(Object? json) {
    if (json is Map<String, dynamic>) {
      final root = json;
      Object? raw = root['data'] ?? root['result'] ?? root;
      if (raw is Map<String, dynamic>) {
        final direct = raw['link'] ?? raw['paymentUrl'] ?? raw['checkoutUrl'];
        if (direct is String && direct.trim().isNotEmpty) return direct.trim();
        final auth = raw['authorization_url'] ?? raw['authorizationUrl'];
        if (auth is String && auth.trim().isNotEmpty) return auth.trim();
      }

      final top = json['link'] ?? json['paymentUrl'] ?? json['checkoutUrl'];
      if (top is String && top.trim().isNotEmpty) return top.trim();
    }
    return null;
  }

  String? _extractTxRef(Object? json) {
    if (json is Map<String, dynamic>) {
      final root = json;
      Object? raw = root['data'] ?? root['result'] ?? root;
      if (raw is Map<String, dynamic>) {
        final direct = raw['tx_ref'] ?? raw['txRef'];
        if (direct is String && direct.trim().isNotEmpty) return direct.trim();
      }

      final top = json['tx_ref'] ?? json['txRef'];
      if (top is String && top.trim().isNotEmpty) return top.trim();
    }
    return null;
  }

  bool _extractCompleted(Object? json) {
    if (json is Map<String, dynamic>) {
      final root = json;
      Object? raw = root['data'] ?? root['result'] ?? root;
      if (raw is Map<String, dynamic>) {
        final direct = raw['completed'];
        if (direct is bool) return direct;
      }

      final top = json['completed'];
      if (top is bool) return top;
    }
    return false;
  }

  bool _extractSuccess(Object? json) {
    if (json is Map<String, dynamic>) {
      final success = json['success'];
      if (success is bool) return success;
      if (success is String) {
        return success.toLowerCase() == 'true' ||
            success.toLowerCase() == 'success';
      }
      final message = json['message'];
      if (message is String) {
        final m = message.toLowerCase();
        if (m.contains('success')) return true;
      }
    }
    return false;
  }

  Future<PaymentInit> initialize({
    required String paymentId,
    required String redirectUrl,
    required int amount,
    bool isBonusPointUsed = false,
    bool isNewPayment = false,
  }) async {
    final json = await _api.initialize(
      paymentId: paymentId,
      redirectUrl: redirectUrl,
      amount: amount,
      isBonusPointUsed: isBonusPointUsed,
      isNewPayment: isNewPayment,
    );

    final url = _extractUrl(json);
    if (url == null || url.isEmpty) {
      throw StateError('Payment initialization did not return a checkout URL');
    }

    final txRef = _extractTxRef(json);
    if (txRef == null || txRef.isEmpty) {
      throw StateError('Payment initialization did not return tx_ref');
    }

    final completed = _extractCompleted(json);

    return PaymentInit(checkoutUrl: url, txRef: txRef, completed: completed);
  }

  Future<bool> verify({required String txRef, String? transactionId}) async {
    final json = await _api.verify(txRef: txRef, transactionId: transactionId);
    return _extractSuccess(json);
  }
}
