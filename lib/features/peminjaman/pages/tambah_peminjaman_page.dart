import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../scan/pages/scan_qr_page.dart';
import '../../../core/database/db_helper.dart';
import 'dart:io';

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
  final ImagePicker _picker = ImagePicker();
  void initState() {
  super.initState();
  tanggalPinjam = DateTime.now();
}

  File? fotoBarang;
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

  Future<void> ambilFoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );

    if (image != null) {
      setState(() {
        fotoBarang = File(image.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📸 Foto berhasil diambil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F8F4),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Tambah Peminjaman',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),)
        ,
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
                      Row(
                        children: [
                          Expanded(
                            child: _inputField(
                              controller: namaBarangController,
                              label: 'Nama Barang',
                              validator: (value) =>
                                  value!.isEmpty ? 'Nama barang wajib diisi' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ScanQrPage()),
                              );

                              if (result != null && result is String) {
                                setState(() {
                                  namaBarangController.text = result;
                                });
                              }
                            },
                          ),
                        ],
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
                            value == null || value.isEmpty
                                ? 'Nama peminjam wajib diisi'
                                : null,
                      ),

                      _inputField(
                        controller: kelasController,
                        label: 'Kelas',
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Kelas wajib diisi'
                                : null,
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DB6AC),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          label: const Text(
                            'Ambil Foto Barang',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          onPressed: ambilFoto, // 🔥 PANGGIL FUNCTION
                        ),
                      ),
                      if (fotoBarang != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              fotoBarang!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6AC),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Simpan Peminjaman',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    if (tanggalPinjam == null || tanggalKembali == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tanggal pinjam & kembali wajib diisi')),
                      );
                      return;
                    }

                    if (tanggalKembali!.isBefore(tanggalPinjam!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tanggal kembali tidak boleh sebelum tanggal pinjam'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    await DBHelper.insertPeminjaman({
                      'nama_barang': namaBarangController.text,
                      'nama_peminjam': namaPeminjamController.text,
                      'kelas': kelasController.text,
                      'instansi': instansiController.text,
                      'tanggal_pinjam': tanggalPinjam!.toIso8601String(),
                      'tanggal_kembali': tanggalKembali!.toIso8601String(),
                      'foto_path': fotoBarang?.path,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Peminjaman berhasil disimpan'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context, true);
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
