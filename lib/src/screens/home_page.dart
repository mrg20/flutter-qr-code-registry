import 'package:flutter/material.dart';
import 'package:flutter_qr_code_registry/src/screens/bar_code_page.dart';
import 'package:flutter_qr_code_registry/src/settings/settings_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.settingsController,
  });

  static const routeName = '/';

  final SettingsController settingsController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String qrCode = '';

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
              onPressed: () async {
                // print('Fitxar entrada'); // Acción al presionar el botón
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BarCodePage(settingsController: widget.settingsController)), // Navega a BarCodePage
                );
                // Ahora 'result' contiene el código QR escaneado
                if (result != null) {
                  print("BAR CODE FOUND!");
                  setState(() {
                    qrCode =
                        result; // Actualizamos la variable 'qrCode' con el valor capturado
                  });
                }
              },
              child: const Text('Fitxar entrada'),
            ),
            ElevatedButton(
              onPressed: () {
                print('Fitxar sortida'); // Acción al presionar el botón
              },
              child: const Text('Fitxar sortida'),
            ),
             SizedBox(height: 30),

            // Mostrar el valor del QR si está disponible
            if (qrCode.isNotEmpty)
            Text(
              'Código QR: $qrCode', // Muestra el código QR escaneado
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
