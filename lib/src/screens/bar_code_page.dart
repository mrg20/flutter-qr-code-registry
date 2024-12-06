import 'package:flutter/material.dart';
import 'package:flutter_qr_code_registry/src/screens/welcome_page.dart';
import 'package:flutter_qr_code_registry/src/settings/settings_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarCodePage extends StatefulWidget {
  static const routeName = '/qr';
  
  const BarCodePage({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<BarCodePage> createState() => _BarCodePageState();
}

class _BarCodePageState extends State<BarCodePage> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
           if (barcodes.isNotEmpty) {
            final barcode = barcodes.first; // Toma solo el primer código detectado
            debugPrint('Barcode found! ${barcode.rawValue}');
            
            // Navega a la página de bienvenida con el nombre extraído del QR
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomePage(name: barcode.rawValue!, settingsController : widget.settingsController),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
