import 'package:flutter/material.dart';
import 'package:flutter_qr_code_registry/src/screens/home_page.dart';
import 'package:flutter_qr_code_registry/src/settings/settings_controller.dart';

class WelcomePage extends StatelessWidget {
  final String name;
    final SettingsController settingsController;


  // Constructor para recibir el nombre (valor del QR)
  const WelcomePage({
    super.key,
    required this.name,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration(seconds: 10), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(settingsController: settingsController)),
        (route) => false,  // Esto elimina todas las rutas anteriores
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text('Benvingut/a!')),
      body: Center(
        child: Text(
          'Benvingut/a $name!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}