import 'package:flutter/material.dart';

class DetailPeminjamanPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailPeminjamanPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Data Peminjam',
              children: [
                _buildItem('Nama', data['nama']),
                _buildItem('Kelas', data['kelas']),
                _buildItem('Instansi', data['instansi']),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: 'Data Barang',
              children: [
                _buildItem('Nama Barang', data['namaBarang']),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: 'Waktu Peminjaman',
              children: [
                _buildItem('Tanggal Pinjam', data['tanggalPinjam']),
                _buildItem('Tanggal Kembali', data['tanggalKembali']),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: 'Penanggung Jawab',
              children: [
                _buildItem('Petugas', data['petugas']),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: 'Foto Barang',
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    data['foto'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ====== WIDGET HELPER ======

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
