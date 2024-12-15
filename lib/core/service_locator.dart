// lib/core/service_locator.dart

import 'package:get_it/get_it.dart';
import 'services/database_service.dart';
import 'services/ble/ble_service.dart';
import 'bloc/device/device_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService.instance);
  getIt.registerLazySingleton<BleService>(() => BleService());

  // BLoCs
  getIt.registerFactory<DeviceBloc>(() => DeviceBloc(
    databaseService: getIt<DatabaseService>(),
    bleService: getIt<BleService>(),
  ));
}