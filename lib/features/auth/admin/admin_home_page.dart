import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_page.dart'; // pastikan file ini ada di folder yang sama
import 'alat_page.dart'; // Import file AlatPage

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserPage()),
      );
    } else if (index == 2) { // Tambahkan navigasi untuk icon Alat
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AlatPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF), // Latar belakang biru muda
      appBar: AppBar(
        // Menambahkan icon panah di sebelah kiri (leading)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Beranda Admin",
          style: TextStyle(
            color: Colors.black, // Mengubah text menjadi hitam
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // 1. KARTU PROFIL ADMIN
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_circle, size: 60, color: Colors.black),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hi, Selamat Datang Admin",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        user?.email ?? "saraswatilingga@gmail.com",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 2. BARIS STATISTIK (Total, Terpinjam, Tersedia)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Total Alat", "50"),
                _buildStatCard("Terpinjam", "30"),
                _buildStatCard("Tersedia", "20"),
              ],
            ),
            const SizedBox(height: 25),

            // 3. CONTAINER TEMPAT GRAFIK (Kosong sesuai permintaan)
            Container(
              width: double.infinity,
              height: 220,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Grafik Peminjaman",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Center(
                      child: Text("Area Grafik (Segera Hadir)"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 4. BOX KOSONG BAWAH
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
            ),
            const SizedBox(height: 100), // Padding bawah agar tidak tertutup navbar
          ],
        ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xff1B607A),
          unselectedItemColor: Colors.black,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Pengguna"),
            BottomNavigationBarItem(icon: Icon(Icons.computer), label: "Alat"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
          ],
        ),
      ),
    );
  }

  // Widget pendukung untuk membuat kartu statistik kecil
  Widget _buildStatCard(String title, String count) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 2)
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.laptop_mac, size: 24),
              const SizedBox(width: 5),
              Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}