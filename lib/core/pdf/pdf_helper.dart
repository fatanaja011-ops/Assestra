import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';


class PdfHelper {
  static Future<String> generateLaporanPdf(
    List<Map<String, dynamic>> data, {
    required String title,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [

          // ===== JUDUL =====
          pw.Center(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          // ===== TABEL =====
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: [

              // ===== HEADER =====
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                children: [
                  _buildHeaderCell("Nama Barang"),
                  _buildHeaderCell("Peminjam"),
                  _buildHeaderCell("Tgl Pinjam"),
                  _buildHeaderCell("Tgl Kembali"),
                ],
              ),

              // ===== DATA =====
              ...data.map((item) {
                return pw.TableRow(
                  children: [
                    _buildDataCell(item['nama_barang']),
                    _buildDataCell(item['nama_peminjam']),
                    _buildDataCell(formatTanggal(item['tanggal_pinjam'])),
                    _buildDataCell(formatTanggal(item['tanggal_kembali'])),
                  ],
                );
              }).toList(),
            ],
          ),

          pw.SizedBox(height: 20),

          // ===== TOTAL =====
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Total Data: ${data.length}",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        "${dir.path}/laporan_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
    return file.path;
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildDataCell(dynamic text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text?.toString() ?? '',
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }
  static String formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '';

    try {
      final parsed = DateTime.parse(tanggal);
      return DateFormat('dd-MM-yyyy').format(parsed);
    } catch (e) {
      return tanggal; 
    }
  }
}
