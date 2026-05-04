import '../entities/payment_method.dart';

abstract class PaymentMethodsRepository {
  Future<List<PaymentMethod>> getPaymentMethods({
    bool forceRefresh = false,
  });
}
