import 'package:flutter/material.dart';
import 'package:flutter_qr_code_registry/src/screens/welcome_page.dart';
import 'package:flutter_qr_code_registry/src/screens/bye_page.dart';
import 'package:flutter_qr_code_registry/src/settings/settings_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_qr_code_registry/src/api/sheets_api.dart';
import 'package:flutter_qr_code_registry/src/screens/error_read.dart';

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
  MobileScannerController cameraController = MobileScannerController(facing: CameraFacing.front);
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) async {
          if (!hasScanned) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              hasScanned = true;
              final barcode = barcodes.first;
              debugPrint('Barcode found! ${barcode.rawValue}');
              
              final isRegistered = await SheetsApi.checkUserInSheet(barcode.rawValue!);
              if (!isRegistered) {
                if(!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ErrorPage(name: barcode.rawValue!, settingsController: widget.settingsController),
                  ),
                );
              }

              if (widget.accessType) {
                await SheetsApi.writeToRegistry(barcode.rawValue!, "Entrada");
                if(!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomePage(name: barcode.rawValue!, settingsController: widget.settingsController),
                  ),
                );
              }else{
                await SheetsApi.writeToRegistry(barcode.rawValue!, "Sortida");
                if(!context.mounted) return;
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
        overlayBuilder: (context, constraints) {
          return Stack(
            children: [
              ColoredBox(
                color: Colors.black.withOpacity(0.5),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3.0,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
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
