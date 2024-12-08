import 'package:flutter/material.dart';
import 'package:flutter_qr_code_registry/src/screens/home_page.dart';
import 'package:flutter_qr_code_registry/src/settings/settings_controller.dart';

class ErrorPage extends StatelessWidget {
  final String name;
    final SettingsController settingsController;

  // Constructor para recibir el nombre (valor del QR)
  const ErrorPage({
    super.key,
    required this.name,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {

    Future.delayed(const Duration(seconds: 3), () {
      if(!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(settingsController: settingsController)),
        (route) => false,  // Esto elimina todas las rutas anteriores
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Error al llegir el QR. És correcte?')),
      body: const Center(
        child: Text(
          'Error al llegir el QR. És correcte?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}