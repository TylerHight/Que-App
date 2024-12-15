// lib/core/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:que_app/core/services/database_service.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'package:que_app/core/database/providers/sqlite_provider.dart';
import 'package:que_app/features/device_settings/repositories/device_settings_repository.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_bloc.dart';
import 'package:que_app/core/models/device/device.dart';

import '../database/repositories/device_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Database
  final sqliteProvider = SQLiteProvider();
  await sqliteProvider.init();
  getIt.registerSingleton<SQLiteProvider>(sqliteProvider);

  // Register DeviceRepository after removing provider parameter since it's not needed
  getIt.registerLazySingleton<DeviceRepository>(
          () => DeviceRepository()
  );

  getIt.registerLazySingleton<DeviceSettingsRepository>(
          () => DeviceSettingsRepository(
        databaseService: getIt<DatabaseService>(),
        bleService: getIt<BleService>(),
      )
  );

  // Services
  getIt.registerLazySingleton<DatabaseService>(
          () => DatabaseService.instance
  );

  getIt.registerLazySingleton<BleService>(() => BleService());

  // Register device settings bloc factory
  getIt.registerFactoryParam<DeviceSettingsBloc, Device, void>(
        (device, _) => DeviceSettingsBloc(
      bleService: getIt<BleService>(),
      device: device,
      repository: getIt<DeviceSettingsRepository>(),
    ),
  );
}