import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy riwayat peminjaman
    final List<Map<String, String>> riwayatData = [
      {"user": "Budi Santoso", "alat": "Laptop HP 14S", "tgl": "10 Feb 2026", "status": "Kembali"},
      {"user": "Siti Aminah", "alat": "Kamera Canon EOS", "tgl": "08 Feb 2026", "status": "Dipinjam"},
      {"user": "Rian Ardianto", "alat": "Mouse HP USB", "tgl": "05 Feb 2026", "status": "Terlambat"},
      {"user": "Dewi Sartika", "alat": "Proyektor Epson", "tgl": "01 Feb 2026", "status": "Kembali"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Riwayat Peminjaman",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Bar Pencarian
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Cari riwayat...",
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),
          ),
          
          // List Riwayat
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: riwayatData.length,
              itemBuilder: (context, index) {
                final item = riwayatData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(3, 3))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffBBD7FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.history_edu, color: Color(0xff1B607A)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['alat']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Peminjam: ${item['user']}", style: const TextStyle(fontSize: 12)),
                            Text(item['tgl']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      _buildStatusLabel(item['status']!),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    Color color;
    if (status == "Kembali") color = Colors.green[700]!;
    else if (status == "Dipinjam") color = const Color(0xff1B607A);
    else color = Colors.red[800]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}