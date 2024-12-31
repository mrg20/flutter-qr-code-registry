import 'package:gsheets/gsheets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';


class SheetsApi {
  static const String _spreadsheetId = '1WC8QSIi7pbyPicuFhpiC2PXeIrfXlXVjhRjnlcjf3ps';
  static Future<String> get _credentials  {
    return rootBundle.loadString('assets/credentials.json');
  }
  static late final GSheets _gsheets;
  static Worksheet? _registrySheet;
  static Worksheet? _userSheet;

  static Future init() async {
    final credentials = await _credentials;
    _gsheets = GSheets(credentials);
    final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
    _registrySheet = _getWorkSheet(spreadsheet, title: 'Registres');
    _userSheet = _getWorkSheet(spreadsheet, title: 'Usuaris');
  }

  static Worksheet _getWorkSheet(Spreadsheet spreadsheet, {required String title}) {
    return spreadsheet.worksheetByTitle(title)!;
  }

  static Future<Uint8List> downloadRegistryAsPdf() async {
    // Get all data from registry sheet
    final values = await _registrySheet!.values.allRows();
    
    // Convert data to CSV format using csv library
    final List<List<dynamic>> csvData = [];
    
    for (var i = 1; i < values.length; i++) {
      var row = values[i];
      if (row.length >= 3) {
        csvData.add(row.sublist(0, 3));
      }
    }

    final String csvString = const ListToCsvConverter().convert(csvData);
    final StringBuffer buffer = StringBuffer();
    buffer.write(csvString);
    
    // Create PDF document
    final pdf = pw.Document();
    // Add page with table
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.TableHelper.fromTextArray(
            headers: ['Treballador', 'Data', 'Tipus Accés'],
            data: csvData,
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignment: pw.Alignment.center,
          );
        },
      ),
    );
    return pdf.save();
  }


  static Future<bool> checkUserInSheet(String user) async {
    final values = await _userSheet!.values.allRows();
    for (var row in values) {
      if (row.length > 1 && row[0] == user) {
        return true;
      }
    }
    return false;
  }

  static Future<void> writeToRegistry(String userId, String accessType) async {
    // Get current date in UTC+1
    final now = DateTime.now().toUtc().add(const Duration(hours: 1));
    final dateStr = "${now.day.toString().padLeft(2,'0')}-${now.month.toString().padLeft(2,'0')}-${now.year} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}";

    // Create row with user ID, timestamp and access type
    final rowData = [userId, dateStr, accessType];
    
    // Write the new row data
    await _registrySheet!.values.appendRow(rowData);
  }
}
