// lib/services/export_pdf_service.dart
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../helpers/database_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class ExportPdfService {
  static Future<String> exportToPdf(String species) async {
    final data = await DatabaseHelper.instance.getAllResponses();
    final filtered = data.where((r) => r['species'] == species).toList();

    final pdf = pw.Document();
    final df = DateFormat('yyyy-MM-dd HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pw.PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Informe SIBA - $species', style: pw.TextStyle(fontSize: 20))),
          pw.Text('Fecha: ${df.format(DateTime.now())}'),
          pw.SizedBox(height: 10),
          ...filtered.map((r) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${r['indicatorTitle'] ?? 'Sin nombre'}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Puntaje: ${r['score'] ?? ''}'),
                  if (r['observaciones'] != null && r['observaciones'].toString().isNotEmpty)
                    pw.Text('Obs: ${r['observaciones']}'),
                  pw.SizedBox(height: 6),
                ],
              ),
            );
          }).toList()
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'informe_${species}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Subir a Storage
    try {
      final ref = FirebaseStorage.instance.ref().child('reports/$fileName');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      print('PDF subido: $url');
    } catch (e) {
      print('Error subiendo pdf: $e');
    }

    return file.path;
  }
}

