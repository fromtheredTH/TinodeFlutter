//import 'package:dio/dio.dart';
import 'package:event_bus_plus/event_bus_plus.dart';
import 'package:get_it/get_it.dart';

// import 'app_api_c.dart';
// import 'app_api_p.dart';
import 'global.dart';

final getIt = GetIt.instance;

setupLocator() async {
  // Register EventBus
  getIt.registerSingleton(EventBus());

  // API
  //final Dio dio = Dio();
  // dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true, error: true));
  // dio.options.connectTimeout = const Duration(minutes: 45);
  // dio.options.receiveTimeout = const Duration(minutes: 30);
  // dio.options.receiveDataWhenStatusError = false;

  // getIt.registerLazySingleton<ApiC>(() => ApiC(dio, baseUrl: API_COMMUNITY_URL));
  // getIt.registerLazySingleton<ApiP>(() => ApiP(dio, baseUrl: API_PLATFORM_URL));

  // // Store
  // getIt.registerSingleton(dio);

  // Register ScopedModels
  //locator.registerFactory<SplashModel>(() => SplashModel());
  //locator.registerFactory<LoginModel>(() => LoginModel());
  //locator.registerFactory<SignupModel>(() => SignupModel());
  //locator.registerFactory<FindModel>(() => FindModel());
}
