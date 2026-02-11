import 'package:flutter/material.dart';
import '../../peminjaman/pages/daftar_peminjaman_page.dart';
import 'cara_pakai_modal.dart';
import '../../../laporan/pages/laporan_bulanan_page.dart';
import '../../../core/database/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isExportMode = false;

  @override
  void initState() {
    super.initState();
    cekArsipOtomatis();
  }

  Future<void> cekArsipOtomatis() async {
    await DBHelper.autoArsipBulanLalu();
    setState(() {});
  }

  void setExportMode(bool value) {
    setState(() {
      isExportMode = value;
    });
  }

  void _showCaraPakaiModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const CaraPakaiModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F4),

      // ===== APPBAR DINAMIS =====
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F8F4),
        elevation: 0,
        automaticallyImplyLeading: !isExportMode,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          isExportMode ? "Export ke PDF" : "Assestra",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF4DB6AC),
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
                _showCaraPakaiModal(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFF4DB6AC)),
              title: const Text('Laporan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LaporanBulananPage(),
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


      body: SafeArea(
        child: DaftarPeminjamanPage(
          isExportMode: isExportMode,
          onExportModeChanged: setExportMode,
        ),
      ),
    );
  }
}
