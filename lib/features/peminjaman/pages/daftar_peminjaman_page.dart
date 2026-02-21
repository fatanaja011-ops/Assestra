import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';
import 'detail_peminjaman_page.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';


class DaftarPeminjamanPage extends StatefulWidget {
  final bool isExportMode;
  final Function(bool) onExportModeChanged;
  final Function(Function())? onPageReady;

  const DaftarPeminjamanPage({
    super.key,
    required this.isExportMode,
    required this.onExportModeChanged,
    this.onPageReady,
  });

  @override
  State<DaftarPeminjamanPage> createState() =>
      _DaftarPeminjamanPageState();
}

class _DaftarPeminjamanPageState
    extends State<DaftarPeminjamanPage> {
  List<Map<String, dynamic>> dataPeminjaman = [];
  bool isLoading = true;

  Set<int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    loadData();
    // Pass loadData callback ke parent
    widget.onPageReady?.call(loadData);
  }

  Future<void> loadData() async {
    final data = await DBHelper.getAllPeminjaman();
    setState(() {
      dataPeminjaman = data;
      isLoading = false;
    });
  }

  void exitExportMode() {
    widget.onExportModeChanged(false);
    setState(() {
      selectedItems.clear();
    });
  }

  Future<void> confirmExport() async {
    if (selectedItems.isEmpty) return;

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text(
            "Apakah kamu ingin mengexport data ini menjadi PDF?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya"),
          ),
        ],
      ),
    );

    if (confirm == true) {

      await DBHelper.exportManualMany(selectedItems.toList());


      await loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil di-export ke Laporan Manual"),
          backgroundColor: Colors.green,
        ),
      );

      exitExportMode();
    }
  }


  Map<String, List<Map<String, dynamic>>> groupByTanggal() {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in dataPeminjaman) {
      DateTime parsedDate =
          DateTime.parse(item['tanggal_pinjam']);
      String tanggal =
          DateFormat('dd-MM-yyyy').format(parsedDate);

      grouped.putIfAbsent(tanggal, () => []);
      grouped[tanggal]!.add(item);
    }

    return grouped;
  }

  int getTotalPeminjamanBulanIni() {
    final now = DateTime.now();
    return dataPeminjaman.where((item) {
      final tgl = DateTime.parse(item['tanggal_pinjam']);
      return tgl.month == now.month && tgl.year == now.year;
    }).length;
  }

  Future<void> generatePdf(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text("Laporan Peminjaman",
              style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 20),
          ...data.map((item) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Barang: ${item['nama_barang']}"),
                pw.Text("Peminjam: ${item['nama_peminjam']}"),
                pw.Text("Kelas: ${item['kelas']}"),
                pw.Text("Tanggal Pinjam: ${item['tanggal_pinjam']}"),
                pw.Text("Tanggal Kembali: ${item['tanggal_kembali']}"),
                pw.Divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );

    // Request permission
    await Permission.manageExternalStorage.request();

    final directory =
        Directory('/storage/emulated/0/Download/Assestra');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File(
        '${directory.path}/Laporan_${DateTime.now().millisecondsSinceEpoch}.pdf');

    await file.writeAsBytes(await pdf.save());

    // Buka PDF
    await OpenFile.open(file.path);
  }


  Widget buildItemCard(Map<String, dynamic> item) {
    final int id = item['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: const Icon(Icons.inventory_2,
            color: Color(0xFF4DB6AC)),
        title: Text(item['nama_barang']),
       subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Peminjam: ${item['nama_peminjam']}"),
            const SizedBox(height: 4),
            Builder(
              builder: (_) {
                try {
                  final tglKembali =
                      DateTime.parse(item['tanggal_kembali']);
                  final formatted =
                      DateFormat('dd-MM-yyyy').format(tglKembali);

                  return Text(
                    "Kembali: $formatted",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  );
                } catch (_) {
                  return const Text("Kembali: -");
                }
              },
            ),
          ],
        ),
        onTap: () {
          if (widget.isExportMode) {
            setState(() {
              selectedItems.contains(id)
                  ? selectedItems.remove(id)
                  : selectedItems.add(id);
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPeminjamanPage(data: item),
              ),
            ).then((_) {
              loadData();
            });
          }
        },
        trailing: widget.isExportMode
            ? Icon(
                selectedItems.contains(id)
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selectedItems.contains(id)
                    ? Colors.green
                    : Colors.grey,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // 🔹 Loading
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 🔹 Kalau data kosong
    if (dataPeminjaman.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Empty-bro.png',
              width: 180,
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Data Peminjaman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan tambah data terlebih dahulu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    final groupedData = groupByTanggal();
    final sortedDates = groupedData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Stack(
      children: [

        // ================= LIST DATA =================
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [

            // 🔹 Card Atas (Bulan Ini & Export)
            if (!widget.isExportMode)
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: const Color(0xFFFF8F00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox(
                        height: 110,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Bulan Ini",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${getTotalPeminjamanBulanIni()} Peminjaman",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        widget.onExportModeChanged(true);
                      },
                      child: Card(
                        color: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const SizedBox(
                          height: 110,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.download,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Export Manual",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // 🔹 Group berdasarkan tanggal
            ...sortedDates.map((tanggal) {
              final items = groupedData[tanggal]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tanggal,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...items.map(buildItemCard),
                ],
              );
            }).toList(),
          ],
        ),

        // ================= BOTTOM EXPORT BAR =================
        if (widget.isExportMode)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF263238),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Pilih minimal 1 data",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: exitExportMode,
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Color(0xFF4DB6AC)),
                        ),
                      ),
                      TextButton(
                        onPressed: confirmExport,
                        child: const Text(
                          "Export",
                          style: TextStyle(color: Color(0xFF4DB6AC)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
