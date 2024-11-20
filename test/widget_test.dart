import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:que_app/models/device_list.dart';
import 'package:que_app/screens/device_control/device_control_screen.dart';
import 'package:que_app/screens/device_control/components/device_remote_card.dart';
import 'package:que_app/screens/device_control/dialogs/add_device_dialog.dart';

void main() {
  testWidgets('Add a new device', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DeviceList()),
        ],
        child: MaterialApp(
          home: DeviceControlScreen(),
        ),
      ),
    );

    // Verify that there are no devices initially
    expect(find.byType(DeviceRemote), findsNothing);

    // Tap on the add device button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that the add device dialog is displayed
    expect(find.byType(AddDeviceDialog), findsOneWidget);

    // Enter device name and tap on Add button in the dialog
    await tester.enterText(find.byType(TextField), 'Test Device');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify that the device is added and displayed
    expect(find.byType(DeviceRemote), findsOneWidget);
    expect(find.text('Test Device'), findsOneWidget);
  });

  testWidgets('Render list of devices', (WidgetTester tester) async {
    // Create a list of devices

    // Build the widget tree
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DeviceList()),
        ],
        child: MaterialApp(
          home: DeviceControlScreen(),
        ),
      ),
    );

    // Verify that the list of devices is rendered correctly
    expect(find.byType(DeviceRemote), findsNWidgets(3));
    expect(find.text('Device 1'), findsOneWidget);
    expect(find.text('Device 2'), findsOneWidget);
    expect(find.text('Device 3'), findsOneWidget);
  });
}
