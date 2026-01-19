import 'package:flutter/material.dart';
import '../../scan/pages/scan_qr_page.dart';


class TambahPeminjamanPage extends StatefulWidget {
  const TambahPeminjamanPage({super.key});

  @override
  State<TambahPeminjamanPage> createState() => _TambahPeminjamanPageState();
}

class _TambahPeminjamanPageState extends State<TambahPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaBarangController = TextEditingController();
  final TextEditingController namaPeminjamController = TextEditingController();
  final TextEditingController kelasController = TextEditingController();
  final TextEditingController instansiController = TextEditingController();

  DateTime? tanggalPinjam;
  DateTime? tanggalKembali;

  Future<void> pilihTanggal(bool isPinjam) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isPinjam) {
          tanggalPinjam = picked;
        } else {
          tanggalKembali = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Peminjaman'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // ================= DATA BARANG =================
              _sectionTitle('Data Barang'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan QR Code'),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ScanQrPage(),
                              ),
                            );

                            if (result != null && result is String && result.isNotEmpty) {
                              setState(() {
                                namaBarangController.text = result;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Barang berhasil di-scan'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _inputField(
                        controller: namaBarangController,
                        label: 'Nama Barang',
                        validator: (value) =>
                            value!.isEmpty ? 'Nama barang wajib diisi' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= DATA PEMINJAM =================
              _sectionTitle('Data Peminjam'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _inputField(
                        controller: namaPeminjamController,
                        label: 'Nama Peminjam',
                        validator: (value) =>
                            value!.isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      _inputField(
                        controller: kelasController,
                        label: 'Kelas',
                        validator: (value) =>
                            value!.isEmpty ? 'Kelas wajib diisi' : null,
                      ),
                      _inputField(
                        controller: instansiController,
                        label: 'Instansi (opsional)',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= WAKTU =================
              _sectionTitle('Waktu & Dokumentasi'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _dateTile(
                        icon: Icons.date_range,
                        title: 'Tanggal Pinjam',
                        date: tanggalPinjam,
                        onTap: () => pilihTanggal(true),
                      ),
                      _dateTile(
                        icon: Icons.event_available,
                        title: 'Tanggal Kembali',
                        date: tanggalKembali,
                        onTap: () => pilihTanggal(false),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Ambil Foto Barang'),
                          onPressed: () {
                            // kamera nanti
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ================= SIMPAN =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Peminjaman'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (tanggalPinjam == null || tanggalKembali == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tanggal pinjam & kembali wajib diisi'),
                          ),
                        );
                        return;
                      }

                      // nanti simpan ke Firebase
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGET BANTUAN =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dateTile({
    required IconData icon,
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        date == null
            ? 'Belum dipilih'
            : date.toString().split(' ')[0],
      ),
      onTap: onTap,
    );
  }
}
