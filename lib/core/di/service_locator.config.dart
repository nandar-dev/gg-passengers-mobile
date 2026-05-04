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
import 'package:gg/features/booking/data/data_sources/booking_remote_data_source.dart'
    as _i615;
import 'package:gg/features/booking/data/data_sources/geocoding_remote_data_source.dart'
    as _i616;
import 'package:gg/features/booking/data/repositories/booking_repository_impl.dart'
    as _i699;
import 'package:gg/features/booking/data/repositories/geocoding_repository_impl.dart'
    as _i381;
import 'package:gg/features/booking/domain/repositories/booking_repository.dart'
    as _i280;
import 'package:gg/features/booking/domain/repositories/geocoding_repository.dart'
    as _i558;
import 'package:gg/features/booking/domain/use_cases/create_booking_use_case.dart'
    as _i7;
import 'package:gg/features/booking/domain/use_cases/get_booking_estimate_use_case.dart'
    as _i859;
import 'package:gg/features/booking/domain/use_cases/get_geocoded_location_use_case.dart'
    as _i763;
import 'package:gg/features/payments/data/data_sources/payment_methods_local_data_source.dart'
    as _i14;
import 'package:gg/features/payments/data/data_sources/payment_methods_remote_data_source.dart'
    as _i415;
import 'package:gg/features/payments/data/repositories/payment_methods_repository_impl.dart'
    as _i499;
import 'package:gg/features/payments/domain/repositories/payment_methods_repository.dart'
    as _i319;
import 'package:gg/features/payments/domain/use_cases/get_payment_methods_use_case.dart'
    as _i387;
import 'package:gg/features/services/data/data_sources/services_local_data_source.dart'
    as _i757;
import 'package:gg/features/services/data/data_sources/services_remote_data_source.dart'
    as _i676;
import 'package:gg/features/services/data/repositories/services_repository_impl.dart'
    as _i578;
import 'package:gg/features/services/domain/repositories/services_repository.dart'
    as _i96;
import 'package:gg/features/services/domain/use_cases/get_services_use_case.dart'
    as _i697;
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
    gh.lazySingleton<_i14.PaymentMethodsLocalDataSource>(
      () => _i14.PaymentMethodsLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i757.ServicesLocalDataSource>(
      () => _i757.ServicesLocalDataSource(gh<_i460.SharedPreferences>()),
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
    gh.lazySingleton<_i615.BookingRemoteDataSource>(
      () => _i615.BookingRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i616.GeocodingRemoteDataSource>(
      () => _i616.GeocodingRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i415.PaymentMethodsRemoteDataSource>(
      () => _i415.PaymentMethodsRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i676.ServicesRemoteDataSource>(
      () => _i676.ServicesRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i96.ServicesRepository>(
      () => _i578.ServicesRepositoryImpl(
        gh<_i676.ServicesRemoteDataSource>(),
        gh<_i757.ServicesLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i1047.AuthRemoteDataSource>(
      () => _i1047.AuthRemoteDataSource(gh<_i1065.AuthApiService>()),
    );
    gh.lazySingleton<_i697.GetServicesUseCase>(
      () => _i697.GetServicesUseCase(gh<_i96.ServicesRepository>()),
    );
    gh.lazySingleton<_i558.GeocodingRepository>(
      () =>
          _i381.GeocodingRepositoryImpl(gh<_i616.GeocodingRemoteDataSource>()),
    );
    gh.lazySingleton<_i763.GetGeocodedLocationUseCase>(
      () => _i763.GetGeocodedLocationUseCase(gh<_i558.GeocodingRepository>()),
    );
    gh.lazySingleton<_i319.PaymentMethodsRepository>(
      () => _i499.PaymentMethodsRepositoryImpl(
        gh<_i415.PaymentMethodsRemoteDataSource>(),
        gh<_i14.PaymentMethodsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i387.GetPaymentMethodsUseCase>(
      () =>
          _i387.GetPaymentMethodsUseCase(gh<_i319.PaymentMethodsRepository>()),
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
    gh.lazySingleton<_i280.BookingRepository>(
      () => _i699.BookingRepositoryImpl(gh<_i615.BookingRemoteDataSource>()),
    );
    gh.lazySingleton<_i7.CreateBookingUseCase>(
      () => _i7.CreateBookingUseCase(gh<_i280.BookingRepository>()),
    );
    gh.lazySingleton<_i859.GetBookingEstimateUseCase>(
      () => _i859.GetBookingEstimateUseCase(gh<_i280.BookingRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i276.RegisterModule {}
