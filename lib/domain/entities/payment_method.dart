/// Método de pago del pedido (simulado).
enum PaymentMethod {
  cash('cash', 'Efectivo'),
  card('card', 'Tarjeta');

  const PaymentMethod(this.firestoreValue, this.label);
  final String firestoreValue;
  final String label;

  static PaymentMethod fromFirestore(String? raw) {
    return PaymentMethod.values.firstWhere(
      (m) => m.firestoreValue == raw,
      orElse: () => PaymentMethod.cash,
    );
  }
}
