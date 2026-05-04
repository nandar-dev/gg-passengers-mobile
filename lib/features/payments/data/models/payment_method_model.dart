import '../../domain/entities/payment_method.dart';

class PaymentMethodModel {
  final String id;
  final String name;
  final String icon;

  const PaymentMethodModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  PaymentMethod toDomain() {
    return PaymentMethod(
      id: id,
      name: name,
      iconUrl: icon,
    );
  }
}
