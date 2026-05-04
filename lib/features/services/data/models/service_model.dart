import 'package:gg/features/services/domain/entities/service_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

@JsonSerializable()
class ServiceModel {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'name_en')
  final String nameEn;
  @JsonKey(name: 'name_mm')
  final String nameMm;

  const ServiceModel({
    required this.id,
    required this.nameEn,
    required this.nameMm,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);

  AppService toDomain() {
    return AppService(
      id: id,
      nameEn: nameEn,
      nameMm: nameMm,
    );
  }

  factory ServiceModel.fromDomain(AppService domain) {
    return ServiceModel(
      id: domain.id,
      nameEn: domain.nameEn,
      nameMm: domain.nameMm,
    );
  }
}
