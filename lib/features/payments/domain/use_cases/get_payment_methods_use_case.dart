import 'package:injectable/injectable.dart';

import '../entities/payment_method.dart';
import '../repositories/payment_methods_repository.dart';

@lazySingleton
class GetPaymentMethodsUseCase {
  final PaymentMethodsRepository _repository;

  const GetPaymentMethodsUseCase(this._repository);

  Future<List<PaymentMethod>> call({bool forceRefresh = false}) {
    return _repository.getPaymentMethods(forceRefresh: forceRefresh);
  }
}
