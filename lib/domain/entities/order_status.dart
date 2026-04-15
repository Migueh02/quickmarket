/// Estados del ciclo de vida de un pedido.
enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  inPreparation('in_preparation'),
  preparing('preparing'),
  onTheWay('on_the_way'),
  delivering('delivering'),
  readyForPickup('ready_for_pickup'),
  assigned('assigned'),
  pickedUp('picked_up'),
  delivered('delivered'),
  cancelled('cancelled');

  const OrderStatus(this.firestoreValue);
  final String firestoreValue;

  static OrderStatus fromFirestore(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.firestoreValue == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
