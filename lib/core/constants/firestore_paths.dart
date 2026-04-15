/// Rutas de colecciones y subcolecciones en Firestore (QuickMarket).
abstract final class FirestorePaths {
  static const String users = 'users';
  static const String stores = 'stores';
  static const String products = 'products';
  static const String orders = 'orders';
  static const String notifications = 'notifications';

  static String userDoc(String uid) => '$users/$uid';
  static String storeDoc(String storeId) => '$stores/$storeId';
  static String productsCol(String storeId) =>
      '$stores/$storeId/$products';
  static String orderDoc(String orderId) => '$orders/$orderId';
  static String userNotificationsCol(String uid) =>
      '$users/$uid/$notifications';
}
