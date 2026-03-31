import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path_provider/path_provider.dart';
import 'package:toolery/database/startdb.dart';

/// Result of a data import operation.
class ImportResult {
  final bool success;
  final bool cancelled;
  final String? errorMessage;

  const ImportResult._({
    required this.success,
    required this.cancelled,
    this.errorMessage,
  });

  factory ImportResult.success() =>
      const ImportResult._(success: true, cancelled: false);

  factory ImportResult.cancelled() =>
      const ImportResult._(success: false, cancelled: true);

  factory ImportResult.error(String message) =>
      ImportResult._(success: false, cancelled: false, errorMessage: message);
}

/// Provides static methods for exporting and importing the app's SQLite
/// database as a collection of CSV files bundled in a ZIP archive.
///
/// **Export** – each database table is serialised to a CSV file; all CSV files
/// are then compressed into a ZIP archive named
/// `toolery-export-<yyyy-MM-dd_HH-mm-ss>.zip` and saved to the device's
/// temporary directory.  The caller is responsible for sharing / saving the
/// returned file path.
///
/// **Import** – the user picks a ZIP file via the system file picker.  The
/// archive is validated (all expected CSV files must be present), and on
/// success the database is cleared and repopulated from the CSV data inside a
/// single transaction.
class DataService {
  // The ordered list of tables.  Import order matters: parent tables must be
  // populated before child tables that reference them.
  static const List<String> tableNames = [
    'tag',
    'affirmation_list',
    'task',
    'breathing',
    'affirmation_items',
    'tasktag',
    'breathingtag',
  ];

  /// Exports all database tables to CSV files compressed into a ZIP archive.
  ///
  /// Returns the path of the generated ZIP file.  Throws on failure.
  static Future<String> exportData() async {
    final db = await getDatabase();
    final archive = Archive();

    for (final tableName in tableNames) {
      final rows = await db.query(tableName);
      final csvContent = _encodeCSV(rows);
      final bytes = utf8.encode(csvContent);
      archive.addFile(ArchiveFile.bytes('$tableName.csv', bytes));
    }

    final zipData = ZipEncoder().encode(archive);

    final now = DateTime.now();
    final timestamp =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}'
        '_${_pad(now.hour)}-${_pad(now.minute)}-${_pad(now.second)}';
    final fileName = 'toolery-export-$timestamp.zip';

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(zipData);

    return file.path;
  }

  /// Opens a file picker so the user can select a `.zip` export archive, then
  /// validates and imports it into the database.
  ///
  /// Returns an [ImportResult] describing the outcome.
  static Future<ImportResult> importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.isEmpty) {
      return ImportResult.cancelled();
    }

    final filePath = result.files.first.path;
    if (filePath == null) {
      return ImportResult.error('Could not read the selected file.');
    }

    final List<int> zipBytes;
    try {
      zipBytes = await File(filePath).readAsBytes();
    } on FileSystemException catch (e) {
      return ImportResult.error('Failed to read file: ${e.message}');
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (_) {
      return ImportResult.error('The selected file is not a valid ZIP archive.');
    }

    // Validate that every required CSV is present.
    final archiveFileNames = archive.files.map((f) => f.name).toSet();
    final missingFiles = tableNames
        .where((t) => !archiveFileNames.contains('$t.csv'))
        .map((t) => '$t.csv')
        .toList();
    if (missingFiles.isNotEmpty) {
      return ImportResult.error(
        'The archive is missing required files: ${missingFiles.join(', ')}',
      );
    }

    final db = await getDatabase();

    try {
      await db.transaction((txn) async {
        // Delete in reverse order to respect foreign-key constraints.
        for (final tableName in tableNames.reversed) {
          await txn.delete(tableName);
        }

        // Insert in forward order so parents exist before children.
        for (final tableName in tableNames) {
          final archiveFile = archive.files.firstWhere(
            (f) => f.name == '$tableName.csv',
          );
          final csvContent = utf8.decode(archiveFile.content);
          final rows = _decodeCSV(csvContent);
          for (final row in rows) {
            await txn.insert(tableName, row);
          }
        }
      });
    } catch (e) {
      return ImportResult.error('Import failed: $e');
    }

    return ImportResult.success();
  }

  /// Encodes [rows] (a list of column-name → value maps) as an RFC 4180 CSV
  /// string.  Returns an empty string when [rows] is empty.
  @visibleForTesting
  static String encodeCSV(List<Map<String, Object?>> rows) =>
      _encodeCSV(rows);

  /// Decodes a RFC 4180 CSV string into a list of column-name → value maps.
  ///
  /// Numeric strings are coerced to [int] or [double] so that SQLite stores
  /// them with the correct type.
  @visibleForTesting
  static List<Map<String, Object?>> decodeCSV(String content) =>
      _decodeCSV(content);

  // ---------------------------------------------------------------------------
  // CSV helpers
  // ---------------------------------------------------------------------------

  /// Encodes [rows] (a list of column-name → value maps) as an RFC 4180 CSV
  /// string.  Returns an empty string when [rows] is empty.
  static String _encodeCSV(List<Map<String, Object?>> rows) {
    if (rows.isEmpty) return '';

    final headers = rows.first.keys.toList();
    final buffer = StringBuffer();

    buffer.writeln(headers.map(_escapeCsvField).join(','));
    for (final row in rows) {
      buffer.writeln(
        headers.map((h) => _escapeCsvField(row[h]?.toString() ?? '')).join(','),
      );
    }

    return buffer.toString();
  }

  /// Wraps [value] in double quotes and escapes any internal double quotes
  /// when the value contains a comma, double quote, carriage return, or
  /// newline.
  static String _escapeCsvField(String? value) {
    final v = value ?? '';
    if (v.contains(',') ||
        v.contains('"') ||
        v.contains('\n') ||
        v.contains('\r')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  /// Decodes a RFC 4180 CSV string into a list of column-name → value maps.
  ///
  /// The first row is treated as headers; subsequent rows become data maps.
  /// Empty trailing lines are silently skipped.  Numeric strings are coerced
  /// to [int] or [double] so that SQLite stores them with the correct type.
  static List<Map<String, Object?>> _decodeCSV(String content) {
    final rows = _parseCsvRows(content);
    if (rows.isEmpty) return [];

    final headers = rows.first;
    final result = <Map<String, Object?>>[];

    for (int i = 1; i < rows.length; i++) {
      final values = rows[i];
      if (values.isEmpty) continue;
      final row = <String, Object?>{};
      for (int j = 0; j < headers.length; j++) {
        final raw = j < values.length ? values[j] : '';
        row[headers[j]] = _coerceValue(raw);
      }
      result.add(row);
    }

    return result;
  }

  /// Coerces a CSV string value to [int], [double], or [String].
  ///
  /// An empty string becomes `null`.  This ensures that numeric columns
  /// (e.g. `id INTEGER`) are inserted with the correct SQLite type.
  static Object? _coerceValue(String value) {
    if (value.isEmpty) return null;
    final intValue = int.tryParse(value);
    if (intValue != null) return intValue;
    final doubleValue = double.tryParse(value);
    if (doubleValue != null) return doubleValue;
    return value;
  }

  /// Splits a CSV string into rows, each row being a list of field strings.
  /// Handles quoted fields (including those that span multiple lines) and
  /// escaped double quotes (`""`).
  static List<List<String>> _parseCsvRows(String content) {
    final rows = <List<String>>[];
    final fields = <String>[];
    final fieldBuffer = StringBuffer();
    bool inQuotes = false;
    int i = 0;

    while (i < content.length) {
      final ch = content[i];

      if (inQuotes) {
        if (ch == '"') {
          // Check for escaped quote (`""`)
          if (i + 1 < content.length && content[i + 1] == '"') {
            fieldBuffer.write('"');
            i += 2;
          } else {
            inQuotes = false;
            i++;
          }
        } else {
          fieldBuffer.write(ch);
          i++;
        }
      } else {
        if (ch == '"') {
          inQuotes = true;
          i++;
        } else if (ch == ',') {
          fields.add(fieldBuffer.toString());
          fieldBuffer.clear();
          i++;
        } else if (ch == '\r') {
          // Handle \r\n and bare \r as line endings.
          fields.add(fieldBuffer.toString());
          fieldBuffer.clear();
          rows.add(List.unmodifiable(fields));
          fields.clear();
          i++;
          if (i < content.length && content[i] == '\n') i++;
        } else if (ch == '\n') {
          fields.add(fieldBuffer.toString());
          fieldBuffer.clear();
          rows.add(List.unmodifiable(fields));
          fields.clear();
          i++;
        } else {
          fieldBuffer.write(ch);
          i++;
        }
      }
    }

    // Flush any remaining content as the last field / row.
    final lastField = fieldBuffer.toString();
    if (fields.isNotEmpty || lastField.isNotEmpty) {
      fields.add(lastField);
      rows.add(List.unmodifiable(fields));
    }

    return rows;
  }

  /// Zero-pads [n] to at least two digits.
  static String _pad(int n) => n.toString().padLeft(2, '0');
}
