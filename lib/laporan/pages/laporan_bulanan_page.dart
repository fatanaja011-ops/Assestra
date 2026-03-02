import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/db_helper.dart';
import 'package:share_plus/share_plus.dart';


class LaporanBulananPage extends StatelessWidget {
  const LaporanBulananPage({super.key});
  String formatBulan(String ym) {
    final date = DateTime.parse('$ym-01');
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.picture_as_pdf,
          color: Color(0xFF4DB6AC),
        ),
        title: buildJudulWidget(item),
        subtitle: Text('${item['total']} peminjaman'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ===== ICON SHARE =====
            IconButton(
              icon: const Icon(
                Icons.share,
                color: Color(0xFF4DB6AC),
              ),
              onPressed: () async {
                final jenis = item['jenis'] as String? ?? '';
                final value = item['bulan'] as String? ?? '';

                String? filePath;

                if (jenis == 'manual') {
                  filePath = await DBHelper.exportPdfManual(value);
                } else {
                  filePath = await DBHelper.exportPdfBulanan(value);
                }

                if (filePath != null) {
                  await Share.shareXFiles([XFile(filePath)]);
                }
              },
            ),
          ],
        ),        
        onTap: () async {
          final jenis = item['jenis'] as String? ?? '';
          final value = item['bulan'] as String? ?? '';

          if (jenis == 'manual') {
            await DBHelper.exportPdfManual(value);
          } else {
            await DBHelper.exportPdfBulanan(value);
          }
        },
      ),
    );
  }


  Widget buildJudulWidget(Map<String, dynamic> item) {
    final jenis = item['jenis'] as String? ?? 'otomatis';
    final value = item['bulan'] as String? ?? '';

    if (jenis == 'manual') {
      if (value.isEmpty) return const Text('Laporan manual');
      try {
        final tanggal = DateTime.parse(value);
        final tanggalStr = DateFormat('dd-MM-yyyy').format(tanggal);
        final jamStr = DateFormat('HH:mm').format(tanggal);

        return Text.rich(
          TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: 'Laporan manual tanggal $tanggalStr '),
              TextSpan(
                text: '($jamStr)',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      } catch (_) {
        return const Text('Laporan manual');
      }
    }

    if (value.isEmpty) return const Text('Laporan');
    return Text(
      'Laporan Bulan ${formatBulan(value)}',
      style: const TextStyle(fontWeight: FontWeight.bold),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
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

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan"));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
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
                ],
              ),
            );
          }

          // ================= FILTER =================
          final laporanManual =
              data.where((item) => item['jenis'] == 'manual').toList();

          final laporanOtomatis =
              data.where((item) => item['jenis'] != 'manual').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // ================= MANUAL =================
              if (laporanManual.isNotEmpty) ...[
                const Text(
                  "Laporan Manual",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...laporanManual.map((item) => _buildCard(item)).toList(),

                const SizedBox(height: 24),
              ],

              // ================= OTOMATIS =================
              if (laporanOtomatis.isNotEmpty) ...[
                const Text(
                  "Laporan Bulanan Otomatis",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...laporanOtomatis.map((item) => _buildCard(item)).toList(),
              ],
            ],
          );
        },
      ),
    );
  }
}
