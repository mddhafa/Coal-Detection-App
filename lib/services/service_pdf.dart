import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateRecapPdf(List data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Monitoring Recap Report",
                style: pw.TextStyle(fontSize: 24),
              ),

              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: [
                  "Year",
                  "day",
                  "Month",
                  "Week",
                  "Coal",
                  "Gangue",
                  "Objects",
                ],
                data:
                    data
                        .map(
                          (e) => [
                            e.year.toString(),
                            e.day?.toString() ?? "-",
                            e.month?.toString() ?? "-",
                            e.week?.toString() ?? "-",
                            e.total_coal.toString(),
                            e.total_gangue.toString(),
                            e.total_objects.toString(),
                          ],
                        )
                        .toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
