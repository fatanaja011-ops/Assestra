import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '/core/database/db_helper.dart';
import '../pages/detail_peminjaman_page.dart';

class DaftarPeminjamanPage extends StatefulWidget {
  const DaftarPeminjamanPage({super.key});

  @override
  State<DaftarPeminjamanPage> createState() => _DaftarPeminjamanPageState();
}

class _DaftarPeminjamanPageState extends State<DaftarPeminjamanPage> {
  List<Map<String, dynamic>> dataPeminjaman = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() => isLoading = true);
    final data = await DBHelper.getAllPeminjaman();
    setState(() {
      dataPeminjaman = data;
      isLoading = false;
    });
  }

  // ===== EMPTY STATE =====
  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/Empty-bro.png',
            width: 220,
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada data peminjaman',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Klik tombol + untuk menambah data',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F4),

      // ===== FLOATING BUTTON =====
      floatingActionButton: FloatingActionButton(
        heroTag: 'fabPeminjaman',
        backgroundColor: const Color(0xFF4DB6AC),
        onPressed: () {
          Navigator.pushNamed(context, '/tambahPeminjaman')
              .then((value) => loadData());
        },
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dataPeminjaman.isEmpty
              ? buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dataPeminjaman.length,
                  itemBuilder: (context, index) {
                    final item = dataPeminjaman[index];

                    return Slidable(
                      key: ValueKey(item['id']),

                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.35,

                        children: [
                          SlidableAction(
                            onPressed: (_) async {
                              await DBHelper.deletePeminjaman(item['id']);
                              loadData();
                            },
                            backgroundColor: const Color(0xFFEF5350),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            borderRadius: BorderRadius.circular(12),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            autoClose: true,
                          ),
                        ],
                      ),
                      // ===== CARD DATA =====
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,

                        child: ListTile(
                          leading: const Icon(
                            Icons.inventory_2,
                            color: Color(0xFF4DB6AC),
                          ),

                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailPeminjamanPage(data: item),
                              ),
                            );

                            if (result == true) {
                              loadData();
                            }
                          },

                          title: Text(item['nama_barang'] ?? '-'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Peminjam: ${item['nama_peminjam']}'),
                              Text('Kelas: ${item['kelas']}'),
                              Text(
                                'Pinjam: ${item['tanggal_pinjam'].toString().split('T')[0]}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
