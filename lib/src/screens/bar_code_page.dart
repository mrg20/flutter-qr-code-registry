import 'package:flutter/material.dart';
import 'package:flutter_qr_code_registry/src/screens/welcome_page.dart';
import 'package:flutter_qr_code_registry/src/screens/bye_page.dart';
import 'package:flutter_qr_code_registry/src/settings/settings_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarCodePage extends StatefulWidget {
  static const routeName = '/qr';
  final bool accessType;
  
  const BarCodePage({
    super.key,
    required this.settingsController,
    required this.accessType
  });

  final SettingsController settingsController;

  @override
  State<BarCodePage> createState() => _BarCodePageState();
}

class _BarCodePageState extends State<BarCodePage> {
  MobileScannerController cameraController = MobileScannerController();
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          if (!hasScanned) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              hasScanned = true;
              final barcode = barcodes.first;
              debugPrint('Barcode found! ${barcode.rawValue}');
              
              if (widget.accessType) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomePage(name: barcode.rawValue!, settingsController: widget.settingsController),
                  ),
                );
              }else{
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ByePage(name: barcode.rawValue!, settingsController: widget.settingsController),
                  ),
                );
              }
            }
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
