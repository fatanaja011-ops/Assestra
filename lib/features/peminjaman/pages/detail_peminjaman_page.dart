import 'dart:io';
import 'package:flutter/material.dart';
import '../../peminjaman/pages/edit_peminjaman_page.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DetailPeminjamanPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailPeminjamanPage({
    super.key,
    required this.data,
  });

  bool get bolehEdit {
    final createdAt = DateTime.parse(data['tanggal_pinjam']);
    return DateTime.now().difference(createdAt).inDays < 1;
  }

  // ================= EXPORT PDF FUNCTION =================
  Future<void> exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'DATA PEMINJAMAN',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Text('Nama Peminjam : ${data['nama_peminjam']}'),
            pw.Text('Kelas         : ${data['kelas']}'),
            pw.Text('Instansi      : ${data['instansi'] ?? '-'}'),

            pw.SizedBox(height: 10),

            pw.Text('Nama Barang   : ${data['nama_barang']}'),

            pw.SizedBox(height: 10),

            pw.Text(
                'Tanggal Pinjam  : ${data['tanggal_pinjam'].substring(0, 10)}'),
            pw.Text(
                'Tanggal Kembali: ${data['tanggal_kembali'].substring(0, 10)}'),

            pw.SizedBox(height: 20),

            if (data['foto_barang'] != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Foto Barang :'),
                  pw.SizedBox(height: 10),
                  pw.Image(
                    pw.MemoryImage(
                      File(data['foto_barang']).readAsBytesSync(),
                    ),
                    width: 200,
                  ),
                ],
              ),
          ],
        );
      },
    ),
  );


    // ===== SIMPAN FILE =====
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/peminjaman_${data['id']}.pdf');
    await file.writeAsBytes(await pdf.save());

    // ===== SHARE FILE =====
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Data Peminjaman',
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F8F4),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Detail Peminjaman',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (bolehEdit)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF4DB6AC)),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPeminjamanPage(data: data),
                  ),
                );

                if (updated == true) {
                  Navigator.pop(context, true);
                }
              },
            )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _section(
              'Data Peminjam',
              [
                _item('Nama', data['nama_peminjam']),
                _item('Kelas', data['kelas']),
                _item('Instansi', data['instansi'] ?? '-'),
              ],
            ),
            _section(
              'Data Barang',
              [
                _item('Nama Barang', data['nama_barang']),
              ],
            ),
            _section(
              'Waktu',
              [
                _item('Tanggal Pinjam',
                    data['tanggal_pinjam'].substring(0, 10)),
                _item('Tanggal Kembali',
                    data['tanggal_kembali'].substring(0, 10)),
              ],
            ),
            if (data['foto_barang'] != null)
              _section(
                'Foto Barang',
                [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(data['foto_barang']),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            if (!bolehEdit)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Data tidak bisa diedit karena sudah lebih dari 1 hari',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20),

            // ===== TOMBOL EXPORT PDF =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DB6AC),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  await exportPdf();
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text(
                  'Export ke PDF',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SMALL WIDGETS =================
  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
