import 'package:flutter/material.dart';
import 'package:flutter_qr_code_registry/src/screens/bar_code_page.dart';
import 'package:flutter_qr_code_registry/src/settings/settings_controller.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_qr_code_registry/src/api/sheets_api.dart';
import 'package:open_file/open_file.dart';

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

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: const Text('Descarregar registre'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Introdueix la contrasenya per descarregar el registre:'),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Contrasenya',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel·lar'),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text == "admin123") { // Replace with your desired password or grab it from config file
                  SheetsApi.downloadRegistryAsPdf().then((pdf) async {
                      String filePath = await FileSaver.instance.saveFile(
                        name: 'registre',
                        bytes: pdf,
                        ext: 'pdf',
                        mimeType: MimeType.pdf
                      );
                      await OpenFile.open(filePath);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registre descarregat correctament'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contrasenya incorrecta'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Descarregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showDownloadDialog,
          ),
        ],
      ),
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BarCodePage(settingsController: widget.settingsController, accessType: true)), // Navega a BarCodePage
                );
                // Ahora 'result' contiene el código QR escaneado
                if (result != null) {
                  setState(() {
                    qrCode =
                        result; // Actualizamos la variable 'qrCode' con el valor capturado
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 83, 163, 107),
              ),
              child: const Text('Fitxar entrada'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BarCodePage(settingsController: widget.settingsController, accessType: false)), // Navega a BarCodePage
                );
                // Ahora 'result' contiene el código QR escaneado
                if (result != null) {
                  setState(() {
                    qrCode =
                        result; // Actualizamos la variable 'qrCode' con el valor capturado
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 117, 155, 156),
              ),
              child: const Text('Fitxar sortida'),
            ),
            const SizedBox(height: 30),

            // Mostrar el valor del QR si está disponible
            if (qrCode.isNotEmpty)
            Text(
              'Código QR: $qrCode', // Muestra el código QR escaneado
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
