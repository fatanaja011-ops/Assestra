import 'package:flutter/material.dart';

class CaraPakaiModal extends StatefulWidget {
  const CaraPakaiModal({super.key});

  @override
  State<CaraPakaiModal> createState() => _CaraPakaiModalState();
}

class _CaraPakaiModalState extends State<CaraPakaiModal> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> slides = [
    {
      "title": "Tambah Peminjaman",
      "desc":
          "Tekan tombol + untuk menambahkan data peminjaman.\nIsi semua data yang diperlukan."
    },
    {
      "title": "Ambil Foto Bukti",
      "desc":
          "Ambil foto sebagai dokumentasi barang agar lebih aman."
    },
    {
      "title": "Detail Peminjaman",
      "desc":
          "Tekan card untuk melihat detail lengkap peminjaman."
    },
    {
      "title": "Export ke PDF",
      "desc":
          "Pilih data lalu tekan tombol Export untuk membuat laporan PDF."
    },
    {
      "title": "Laporan Bulanan",
      "desc":
          "Buka menu Drawer untuk melihat laporan bulanan."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F8F4),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        size: 90,
                        color: Color(0xFF4DB6AC),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        slides[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        slides[index]["desc"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (index) => Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 4),
                width: currentPage == index ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? const Color(0xFF4DB6AC)
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                        color: Color(0xFF4DB6AC)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF4DB6AC),
                  ),
                  onPressed: () {
                    if (currentPage ==
                        slides.length - 1) {
                      Navigator.pop(context);
                    } else {
                      _controller.nextPage(
                        duration:
                            const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    currentPage ==
                            slides.length - 1
                        ? "Selesai"
                        : "Selanjutnya",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
