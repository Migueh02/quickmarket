import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/domain/entities/payment_method.dart';
import 'package:quickmarket/presentation/providers/session_providers.dart';

class CheckoutFormState {
  const CheckoutFormState({
    this.address = '',
    this.paymentMethod = PaymentMethod.cash,
  });

  final String address;
  final PaymentMethod paymentMethod;

  CheckoutFormState copyWith({
    String? address,
    PaymentMethod? paymentMethod,
  }) {
    return CheckoutFormState(
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class CheckoutFormNotifier extends StateNotifier<CheckoutFormState> {
  CheckoutFormNotifier(String? initialAddress)
      : super(CheckoutFormState(address: initialAddress ?? ''));

  void setAddress(String value) => state = state.copyWith(address: value);

  void setPaymentMethod(PaymentMethod value) {
    state = state.copyWith(paymentMethod: value);
  }
}

final checkoutFormProvider = StateNotifierProvider.autoDispose<
    CheckoutFormNotifier, CheckoutFormState>(
  (ref) {
    final city = ref.watch(userProfileProvider).valueOrNull?.city;
    final initial = city == null || city.isEmpty ? '' : 'Entrega en $city';
    return CheckoutFormNotifier(initial);
  },
);
