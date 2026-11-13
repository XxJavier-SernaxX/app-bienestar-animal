// lib/services/export_service.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../helpers/database_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ExportService {
  static Future<String> exportToExcel(String species) async {
    final db = DatabaseHelper.instance;
    final data = await db.getAllResponses();
    final filtered = data.where((r) => r['species'] == species).toList();

    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Resultados'];

    // encabezados
    sheet.appendRow([
      TextCellValue('IndicatorId'),
      TextCellValue('IndicatorTitle'),
      TextCellValue('Score'),
      TextCellValue('Timestamp'),
      TextCellValue('Evaluador'),
      TextCellValue('Fecha Evaluacion'),
      TextCellValue('Observaciones'),
      TextCellValue('Species'),
      TextCellValue('PhotoPath')
    ]);

    for (var r in filtered) {
      sheet.appendRow([
        TextCellValue(r['indicatorId']?.toString() ?? ''),
        TextCellValue(r['indicatorTitle']?.toString() ?? ''),
        TextCellValue(r['score']?.toString() ?? ''),
        TextCellValue(r['timestamp']?.toString() ?? ''),
        TextCellValue(r['evaluador']?.toString() ?? ''),
        TextCellValue(r['fecha_evaluacion']?.toString() ?? ''),
        TextCellValue(r['observaciones']?.toString() ?? ''),
        TextCellValue(r['species']?.toString() ?? ''),
        TextCellValue(r['photo']?.toString() ?? ''),
      ]);
    }

    // Guardar archivo localmente
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'resultados_${species}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.save();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(fileBytes!, flush: true);

    // Subir a Firebase Storage (opcional)
    try {
      final ref = FirebaseStorage.instance.ref().child('exports/$fileName');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      print('Excel subido: $url');
    } catch (e) {
      print('Error subiendo excel: $e');
    }

    return file.path; // retorna la ruta local
  }
}
