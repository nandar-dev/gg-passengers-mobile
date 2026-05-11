import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../providers/profile_notifier.dart';
import 'service_locator.config.dart';

final getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies() async {
  await getIt.init();
  getIt.registerLazySingleton<ProfileNotifier>(() => ProfileNotifier());
}
