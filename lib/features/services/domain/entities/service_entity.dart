class AppService {
  final String id;
  final String nameEn;
  final String nameMm;

  const AppService({
    required this.id,
    required this.nameEn,
    required this.nameMm,
  });

  String getName(String languageCode) {
    return languageCode == 'mm' ? nameMm : nameEn;
  }
}
