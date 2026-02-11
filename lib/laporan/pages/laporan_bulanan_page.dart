import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/db_helper.dart';

class LaporanBulananPage extends StatelessWidget {
  const LaporanBulananPage({super.key});

  String formatBulan(String ym) {
    final date = DateTime.parse('$ym-01');
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper.getLaporanBulanan(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/kosong.png',
                    width: 180,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum Ada Laporan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Laporan akan muncul otomatis\nsetiap tanggal 1',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            );
          }


          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf,
                    color: Color(0xFF4DB6AC),
                  ),
                  title: Text(
                    'Laporan Bulan ${formatBulan(item['bulan'])}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${item['total']} peminjaman'),
                  trailing: IconButton(
                    icon: const Icon(Icons.share, color: Color(0xFF4DB6AC)),
                    onPressed: () {
                      // TODO: share pdf
                    },
                  ),
                  onTap: () {
                    // TODO: buka pdf
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
