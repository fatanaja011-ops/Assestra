import 'package:flutter/material.dart';
import 'tambah_peminjaman_page.dart';

class DaftarPeminjamanPage extends StatefulWidget {
  const DaftarPeminjamanPage({super.key});

  @override
  State<DaftarPeminjamanPage> createState() => _DaftarPeminjamanPageState();
}

class _DaftarPeminjamanPageState extends State<DaftarPeminjamanPage> {
  final List<Map<String, dynamic>> dataPeminjaman = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Peminjaman'),
      ),

      body: dataPeminjaman.isEmpty
          ? const Center(
              child: Text(
                'Belum ada data peminjaman',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dataPeminjaman.length,
              itemBuilder: (context, index) {
                final item = dataPeminjaman[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.inventory),
                    title: Text(item['namaBarang']),
                    subtitle: Text(
                      '${item['nama']} • ${item['kelas']}',
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahPeminjamanPage(),
            ),
          );

          if (result != null) {
            setState(() {
              dataPeminjaman.add(result);
            });
          }
        },
      ),
    );
  }
}
