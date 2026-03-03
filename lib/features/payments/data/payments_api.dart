import '../../../core/network/api_client.dart';

class PaymentsApi {
  PaymentsApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> initialize({
    required String paymentId,
    required String redirectUrl,
    required int amount,
    bool isBonusPointUsed = false,
    bool isNewPayment = false,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/payments/initialize',
      data: <String, dynamic>{
        'paymentId': paymentId,
        'redirectUrl': redirectUrl,
        'platform': 'mobile',
        'amount': amount,
        'isBonusPointUsed': isBonusPointUsed,
        'isNewPayment': isNewPayment,
      },
    );
  }

  Future<Map<String, dynamic>> verify({
    required String txRef,
    String? transactionId,
  }) {
    return _client.get<Map<String, dynamic>>(
      '/payments/callback',
      queryParameters: <String, dynamic>{
        'tx_ref': txRef,
        if (transactionId != null && transactionId.isNotEmpty)
          'transaction_id': transactionId,
        'status': 'completed',
      },
    );
  }
}
