import 'package:flutter/material.dart';
import '../../../../core/database/db_helper.dart';

class EditPeminjamanPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditPeminjamanPage({super.key, required this.data});

  @override
  State<EditPeminjamanPage> createState() => _EditPeminjamanPageState();
}

class _EditPeminjamanPageState extends State<EditPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController namaBarangController;
  late TextEditingController namaPeminjamController;
  late TextEditingController kelasController;
  late TextEditingController instansiController;

  DateTime? tanggalKembali;

  @override
  void initState() {
    super.initState();
    namaBarangController =
        TextEditingController(text: widget.data['nama_barang']);
    namaPeminjamController =
        TextEditingController(text: widget.data['nama_peminjam']);
    kelasController = TextEditingController(text: widget.data['kelas']);
    instansiController =
        TextEditingController(text: widget.data['instansi']);
    tanggalKembali =
        DateTime.parse(widget.data['tanggal_kembali']);
  }

  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggalKembali ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => tanggalKembali = picked);
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
          'Edit',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(namaBarangController, 'Nama Barang'),
              _input(namaPeminjamController, 'Nama Peminjam'),
              _input(kelasController, 'Kelas'),
              _input(instansiController, 'Instansi (opsional)', required: false),

              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Tanggal Kembali'),
                subtitle: Text(
                  tanggalKembali!.toString().substring(0, 10),
                ),
                onTap: pilihTanggal,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6AC),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await _simpan(); 
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: required
            ? (v) => v!.isEmpty ? '$label wajib diisi' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),

          filled: true,
          fillColor: const Color(0xFFF1F8F4), 

          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 1.5),
          ),
        ),
      ),
    );
  }

  

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    await DBHelper.updatePeminjaman(
      widget.data['id'],
      {
        'nama_barang': namaBarangController.text,
        'nama_peminjam': namaPeminjamController.text,
        'kelas': kelasController.text,
        'instansi': instansiController.text,
        'tanggal_kembali': tanggalKembali!.toIso8601String(),
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil diperbarui')),
    );

    Navigator.pop(context, true);
  }
}
