import 'package:flutter/material.dart';
import 'package:flutter_qr_code_registry/src/settings/settings_controller.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({
    super.key,
    required this.settingsController,
  });

  static const routeName = '/';

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    Widget page;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/barnola.jpg',
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                  print('Fitxar entrada'); // Acción al presionar el botón
                },
              child: const Text('Fitxar entrada'),
            ),
            ElevatedButton(
              onPressed: () {
                  print('Fitxar sortida'); // Acción al presionar el botón
                },
              child: const Text('Fitxar sortida'),
            ),
          ],
        ),
      ),
    );
  }
}
