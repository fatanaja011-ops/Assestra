import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';
import 'tambah_peminjaman_page.dart';
import 'detail_peminjaman_page.dart';
import 'package:intl/intl.dart';

class DaftarPeminjamanPage extends StatefulWidget {
  final bool isExportMode;
  final Function(bool) onExportModeChanged;

  const DaftarPeminjamanPage({
    super.key,
    required this.isExportMode,
    required this.onExportModeChanged,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil di export ke PDF"),
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
        subtitle:
            Text("Peminjam: ${item['nama_peminjam']}"),
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
    final groupedData = groupByTanggal();
    final sortedDates = groupedData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Stack(
      children: [
        isLoading
            ? const Center(
                child: CircularProgressIndicator())
            : ListView(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  if (!widget.isExportMode)
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: const Color(0xFFFF8F00),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              height: 110,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
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
                                        fontWeight:
                                            FontWeight.bold,
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
                            borderRadius:
                                BorderRadius.circular(16),
                            onTap: () {
                              widget.onExportModeChanged(true);
                            },
                            child: Card(
                              color:
                                  const Color(0xFF1976D2),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: const SizedBox(
                                height: 110,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons.download,
                                        size: 28,
                                        color:
                                            Colors.white,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Export Manual",
                                        style: TextStyle(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
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
                  ...sortedDates.map((tanggal) {
                    final items =
                        groupedData[tanggal]!;
                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(tanggal,
                            style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...items.map(buildItemCard),
                      ],
                    );
                  }).toList(),
                ],
              ),

        if (!widget.isExportMode)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor:
                  const Color(0xFF4DB6AC),
              child: const Icon(Icons.add,
                  color: Colors.white),
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      const TambahPeminjamanPage(),
                );
                loadData();
              },
            ),
          ),

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
                    style: TextStyle(
                        color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      TextButton(
                        onPressed:
                            exitExportMode,
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                              color: Color(
                                  0xFF4DB6AC)),
                        ),
                      ),
                      TextButton(
                        onPressed:
                            confirmExport,
                        child: const Text(
                          "Export",
                          style: TextStyle(
                              color: Color(
                                  0xFF4DB6AC)),
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
