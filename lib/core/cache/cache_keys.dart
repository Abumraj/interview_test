class CacheKeys {
  static const String productsList = 'products_list';

  static String productDetails(String id) => 'product_details_$id';

  static const String eventsList = 'events_list';

  static String eventDetails(String id) => 'event_details_$id';

  static const String purchasesList = 'purchases_list';

  static const String activePaymentId = 'active_payment_id';

  static const String ticketsList = 'tickets_list';
}
