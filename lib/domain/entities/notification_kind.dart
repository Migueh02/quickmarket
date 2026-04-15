/// Tipo de aviso in-app (persistido en Firestore como `kind`).
enum NotificationKind {
  orderPlaced('order_placed'),
  orderConfirmed('order_confirmed'),
  orderPreparing('order_preparing'),
  orderReady('order_ready'),
  driverAssigned('driver_assigned'),
  pickedUp('picked_up'),
  onTheWay('on_the_way'),
  delivered('delivered'),
  cancelled('cancelled'),
  generic('generic');

  const NotificationKind(this.firestoreValue);
  final String firestoreValue;

  static NotificationKind fromFirestore(String? raw) {
    if (raw == null || raw.isEmpty) return NotificationKind.generic;
    for (final v in NotificationKind.values) {
      if (v.firestoreValue == raw) return v;
    }
    return NotificationKind.generic;
  }
}
