import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/database/db_helper.dart';

Future<void> exportPdfBulanan(
  String bulan, {
  required bool share,
}) async {
  final pdf = pw.Document();

  final data = await DBHelper.getPeminjamanByBulan(bulan);

  pdf.addPage(
    pw.Page(
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Laporan Peminjaman Bulan $bulan',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),

          ...data.map(
            (e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(
                '- ${e['nama_barang']} | ${e['nama_peminjam']} | ${e['kelas']}',
              ),
            ),
          ),
        ],
      ),
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/laporan_$bulan.pdf');
  await file.writeAsBytes(await pdf.save());

  if (share) {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Laporan Peminjaman Bulan $bulan',
    );
  } else {
    await OpenFile.open(file.path);
  }
}
