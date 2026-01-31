import 'package:flutter/material.dart';
import '../../peminjaman/pages/daftar_peminjaman_page.dart';
import '../../peminjaman/pages/tambah_peminjaman_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== BACKGROUND WARNA MODERN =====
      backgroundColor: const Color(0xFFF1F8F4),

      // ===== DRAWER =====
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color (0xFF4DB6AC),
              ),
              accountName: Text(
                'Assestra',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text('Aplikasi Peminjaman Barang'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.inventory_2,
                  size: 40,
                  color: Color(0xFF4DB6AC),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF4DB6AC)),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Tentang Assestra'),
                    content: const Text(
                      'Assestra adalah aplikasi peminjaman barang '
                      'yang membantu pencatatan peminjaman agar lebih rapi '
                      'dan mudah dipantau.\n\n'
                      'Dibuat untuk kebutuhan sekolah.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.menu_book, color: Color(0xFF4DB6AC)),
              title: const Text('Cara Pakai'),
              onTap: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Cara Menggunakan Assestra'),
                    content: const Text(
                      '1. Tekan tombol + untuk menambah peminjaman\n'
                      '2. Isi data barang dan peminjam\n'
                      '3. Pilih tanggal pinjam & kembali\n'
                      '4. Simpan data peminjaman\n\n'
                      'Data akan otomatis tersimpan dan tampil di daftar.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Mengerti'),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(),

            const ListTile(
              leading: Icon(Icons.verified, color: Color(0xFF4DB6AC)),
              title: Text('Versi Aplikasi'),
              subtitle: Text('v1.0.0'),
            ),
          ],
        ),
      ),



      // ===== BODY =====
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER CUSTOM =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Assestra',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ===== LIST PEMINJAMAN =====
            const Expanded(
              child: DaftarPeminjamanPage(),
            ),
          ],
        ),
      ),

      // ===== FLOATING BUTTON TAMBAH =====
      floatingActionButton: FloatingActionButton(
        heroTag: 'fabhome',
        backgroundColor: const Color(0xFF4DB6AC),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
        
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahPeminjamanPage(),
            ),
          );
        },
      ),
    );
  }
}
