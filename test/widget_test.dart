import 'package:flutter_test/flutter_test.dart';
import 'package:quickmarket/domain/entities/order_status.dart';

void main() {
  test('OrderStatus.fromFirestore reconoce valores persistidos', () {
    expect(OrderStatus.fromFirestore('pending'), OrderStatus.pending);
    expect(OrderStatus.fromFirestore('ready_for_pickup'), OrderStatus.readyForPickup);
  });
}
