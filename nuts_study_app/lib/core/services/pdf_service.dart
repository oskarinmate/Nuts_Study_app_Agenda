import 'package:nuts_study_app/features/lists/models/note_list_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/models/note_model.dart';
 // Ajusta según tu ruta

class PdfService {
  // EXPORTAR NOTA
  static Future<void> exportNote(Note note) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            // AQUÍ ESTABA EL ERROR: El nombre correcto es crossAxisAlignment
            crossAxisAlignment: pw.CrossAxisAlignment.start, 
            children: [
              pw.Text(
                note.title ?? "Sin título",
                style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Text(
                note.content ?? "",
                style: const pw.TextStyle(fontSize: 16),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${note.title ?? "Nota"}.pdf',
    );
  }

  

  // En pdf_service.dart
static Future<void> exportList(String title, List<dynamic> items) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 15),
            ...items.map((item) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  children: [
                    // Dibujamos un cuadradito según el estado isDone
                    pw.Container(
                      width: 12,
                      height: 12,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1),
                        color: item.isDone ? PdfColors.grey300 : null,
                      ),
                      child: item.isDone 
                        ? pw.Center(child: pw.Text("x", style: const pw.TextStyle(fontSize: 8))) 
                        : null,
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      item.text,
                      style: pw.TextStyle(
                        fontSize: 16,
                        // Si está hecho, le damos un tono gris al texto
                        color: item.isDone ? PdfColors.grey : PdfColors.black,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: 'Lista_$title.pdf',
  );
}
}