import 'package:flutter/material.dart';
import 'package:flutter_qr_code_registry/src/screens/home_page.dart';
import 'settings/settings_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 32, 57)),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          home: HomePage(settingsController: settingsController),
        );
      },
    );
  }
}
