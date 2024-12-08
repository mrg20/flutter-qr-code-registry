import 'package:gsheets/gsheets.dart';
import 'package:flutter/services.dart' show rootBundle;


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
