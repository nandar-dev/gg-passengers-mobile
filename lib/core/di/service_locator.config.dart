// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:gg/core/di/register_module.dart' as _i276;
import 'package:gg/core/network/interceptors/auth_interceptor.dart' as _i354;
import 'package:gg/core/network/interceptors/auth_refresh_interceptor.dart'
    as _i30;
import 'package:gg/core/network/token_storage.dart' as _i965;
import 'package:gg/features/auth/data/data_sources/auth_api_service.dart'
    as _i1065;
import 'package:gg/features/auth/data/data_sources/auth_remote_data_source.dart'
    as _i1047;
import 'package:gg/features/auth/data/repositories/auth_repository_impl.dart'
    as _i490;
import 'package:gg/features/auth/domain/repositories/auth_repository.dart'
    as _i529;
import 'package:gg/features/auth/domain/use_cases/login_passenger_use_case.dart'
    as _i38;
import 'package:gg/features/auth/domain/use_cases/refresh_passenger_token_use_case.dart'
    as _i821;
import 'package:gg/features/auth/domain/use_cases/register_passenger_use_case.dart'
    as _i819;
import 'package:gg/features/auth/domain/use_cases/verify_passenger_otp_use_case.dart'
    as _i330;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i965.TokenStorage>(
      () => registerModule.tokenStorage(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i354.AuthInterceptor>(
      () => registerModule.authInterceptor(gh<_i965.TokenStorage>()),
    );
    gh.lazySingleton<_i30.AuthRefreshInterceptor>(
      () => registerModule.authRefreshInterceptor(gh<_i965.TokenStorage>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<_i354.AuthInterceptor>(),
        gh<_i30.AuthRefreshInterceptor>(),
      ),
    );
    gh.lazySingleton<_i1065.AuthApiService>(
      () => _i1065.AuthApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1047.AuthRemoteDataSource>(
      () => _i1047.AuthRemoteDataSource(gh<_i1065.AuthApiService>()),
    );
    gh.lazySingleton<_i529.AuthRepository>(
      () => _i490.AuthRepositoryImpl(
        gh<_i1047.AuthRemoteDataSource>(),
        gh<_i965.TokenStorage>(),
      ),
    );
    gh.lazySingleton<_i38.LoginPassengerUseCase>(
      () => _i38.LoginPassengerUseCase(gh<_i529.AuthRepository>()),
    );
    gh.lazySingleton<_i821.RefreshPassengerTokenUseCase>(
      () => _i821.RefreshPassengerTokenUseCase(gh<_i529.AuthRepository>()),
    );
    gh.lazySingleton<_i819.RegisterPassengerUseCase>(
      () => _i819.RegisterPassengerUseCase(gh<_i529.AuthRepository>()),
    );
    gh.lazySingleton<_i330.VerifyPassengerOtpUseCase>(
      () => _i330.VerifyPassengerOtpUseCase(gh<_i529.AuthRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i276.RegisterModule {}
