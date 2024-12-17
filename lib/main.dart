import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/database/migrations/migration_service.dart';
import 'core/services/database_service.dart';
import 'core/services/ble/ble_service.dart';
import 'features/device_control/bloc/device_control_bloc.dart';
import 'package:que_app/core/models/notes_list.dart';

import 'features/device_control/views/device_control_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await MigrationService.initializeDatabase();

  // Initialize the database service
  final databaseService = DatabaseService.instance;

  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;

  const MyApp({
    super.key,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(
          value: databaseService,
        ),
        Provider<BleService>(
          create: (_) => BleService(),
        ),
        BlocProvider(
          create: (context) => DeviceControlBloc(
            databaseService: context.read<DatabaseService>(),
            bleService: context.read<BleService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => NotesList()),
      ],
      child: MaterialApp(
        title: 'Que App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const DeviceControlScreen(),
        },
      ),
    );
  }
}