import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  final today = DateTime.now();

  DateTime initialDate = today;
  DateTime firstDate = DateTime(2020);

  if (isPinjam) {
    initialDate = today;
    firstDate = DateTime(today.year, today.month, today.day);
  } else {
   
    initialDate = tanggalPinjam ?? today;
    final minDate = tanggalPinjam ?? today;
    firstDate = DateTime(minDate.year, minDate.month, minDate.day);
  }

  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: DateTime(2030),
    selectableDayPredicate: (day) {
      final min = DateTime(firstDate.year, firstDate.month, firstDate.day);
      return !day.isBefore(min);
    },
    builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4DB6AC),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isPinjam) {
          tanggalPinjam = picked;

          if (tanggalKembali != null && tanggalKembali!.isBefore(tanggalPinjam!)) {
            tanggalKembali = null;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tanggal kembali direset karena lebih awal dari tanggal pinjam. Silakan pilih kembali.'),
              ),
            );
          }
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

    if (image == null) return;

    final directory =
        await getApplicationDocumentsDirectory();

    final String newPath =
        '${directory.path}/bukti_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final File newImage =
        await File(image.path).copy(newPath);

    setState(() {
      fotoBarang = newImage;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Foto berhasil disimpan permanen'),
      ),
    );
  }

  Future<void> simpanData() async {
    await DBHelper.insertPeminjaman({
      'nama_barang': namaBarangController.text,
      'nama_peminjam': namaPeminjamController.text,
      'kelas': kelasController.text,
      'instansi': instansiController.text,
      'tanggal_pinjam': tanggalPinjam!.toIso8601String(),
      'tanggal_kembali': tanggalKembali!.toIso8601String(),
      'foto_path': fotoBarang?.path,
    });

    Navigator.pop(context, true);
  }

  Future<void> showWarningFoto() async {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Peringatan"),
          content: const Text(
            "Apakah anda yakin tanpa ambil foto bukti?",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ambilFoto();

                if (fotoBarang != null) {
                  await simpanData();
                }
              },
              child: const Text(
                "Ambil Foto",
                style: TextStyle(color: Color(0xFF4DB6AC)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await simpanData();
              },
              child: const Text(
                "Tidak perlu",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }


  @override
    Widget build(BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== JUDUL =====
                const Center(
                  child: Text(
                    'Tambah Peminjaman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= DATA BARANG =================
                _sectionTitle('Data Barang'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
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
                              MaterialPageRoute(
                                builder: (_) => const ScanQrPage(),
                              ),
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
                              value!.isEmpty ? 'Nama peminjam wajib diisi' : null,
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

                // ================= WAKTU & FOTO =================
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
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DB6AC),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            label: const Text(
                              'Ambil Foto Bukti',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            onPressed: ambilFoto,
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
                    icon: const Icon(Icons.save, color: Colors.white,),
                    label: const Text(
                      'Simpan Peminjaman',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      if (tanggalPinjam == null || tanggalKembali == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tanggal pinjam & kembali wajib diisi'),
                          ),
                        );
                        return;
                      }
                      
                      if (tanggalKembali!.isBefore(tanggalPinjam!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tanggal kembali tidak boleh lebih awal dari tanggal pinjam'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (fotoBarang == null) {
                        await showWarningFoto();
                      } else {
                        await simpanData();
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
