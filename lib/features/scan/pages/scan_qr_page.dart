import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends StatelessWidget {
  const ScanQrPage({super.key});

  bool isValidAssafScan(String data) {
    return data.contains('Barang:');
  }

  String extractNamaBarang(String data) {
    final lines = data.split('\n');
    for (var line in lines) {
      if (line.startsWith('Barang:')) {
        return line.replaceFirst('Barang:', '').trim();
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Barang'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final String? rawValue = barcode.rawValue;

          if (rawValue == null) return;

          if (!isValidAssafScan(rawValue)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ QR bukan dari AssafScan'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final namaBarang = extractNamaBarang(rawValue);

          Navigator.pop(context, namaBarang);
        },
      ),
    );
  }
}
