import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../peminjaman/pages/edit_peminjaman_page.dart';

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
                _item('Tanggal Pinjam', _formatDate(data['tanggal_pinjam'])),
                _item('Tanggal Kembali', _formatDate(data['tanggal_kembali'])),
              ],
            ),
            if (data['foto_path'] != null && data['foto_path'].toString().isNotEmpty)
              _section(
                'Foto Bukti',
                [
                  Builder(
                    builder: (_) {
                      final file = File(data['foto_path']);

                      if (!file.existsSync()) {
                        return const Text(
                          "File foto tidak ditemukan",
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          file,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
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

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      try {
        return iso.substring(0, 10);
      } catch (_) {
        return iso;
      }
    }
  }
}
