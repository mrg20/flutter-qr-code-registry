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

  static String extractdate(date){
    // Parse days and fractional time from Excel timestamp
        final excelTimestamp = double.parse(date);
        final days = excelTimestamp.toInt();
        final fractionalDay = excelTimestamp - days;
        
        // Convert to DateTime starting from Excel epoch
        final dateTime = DateTime(1899, 12, 30)
            .add(Duration(days: days))
            // Convert fractional day to milliseconds (24*60*60*1000 ms in a day)
            .add(Duration(milliseconds: (fractionalDay * 24 * 60 * 60 * 1000).round()));
            
        // Convert to UTC+1 by adding 1 hour
        final utcPlus1DateTime = dateTime.toUtc().add(const Duration(hours: 1));
            
        return "${utcPlus1DateTime.day.toString().padLeft(2,'0')}-${utcPlus1DateTime.month.toString().padLeft(2,'0')}-${utcPlus1DateTime.year} ${utcPlus1DateTime.hour.toString().padLeft(2,'0')}:${utcPlus1DateTime.minute.toString().padLeft(2,'0')}:${utcPlus1DateTime.second.toString().padLeft(2,'0')}";
  }

  static Future<Uint8List> downloadRegistryAsPdf() async {
    // Get all data from registry sheet
    final values = await _registrySheet!.values.allRows();
    
    // Convert data to CSV format using csv library
    final List<List<dynamic>> csvData = [];
    
    for (var i = 1; i < values.length; i++) {
      var row = values[i];
      if (row.length >= 3) {
        row[1] = extractdate(row[1]);
        // Replace user ID with full name from user sheet
        final userValues = await _userSheet!.values.allRows();
        for (var userRow in userValues) {
          if (userRow.length > 1 && userRow[0] == row[0]) {
            row[0] = userRow[1];
            break;
          }
        }
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
