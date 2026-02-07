import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final supabase = Supabase.instance.client;

  // Data Dummy agar tampilan penuh saat di-run
  int totalAlat = 50;
  int totalDipinjam = 30;
  int totalTersedia = 20;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF), // Biru latar belakang
      appBar: AppBar(
        title: const Text(
          "Beranda Admin",
          style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            /// HEADER USER (PROFILE)
            _buildNeoBox(
              child: Row(
                children: [
                  const Icon(Icons.account_circle, size: 70, color: Colors.black),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hi, Selamat Datang Admin",
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        Text(
                          user?.email ?? "saraswatielingga@gmail.com",
                          style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ROW CARD INFO (TOTAL, TERPINJAM, TERSEDIA)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Total Alat", totalAlat),
                _buildStatCard("Terpinjam", totalDipinjam),
                _buildStatCard("Tersedia", totalTersedia),
              ],
            ),

            const SizedBox(height: 25),

            /// GRAFIK BOX
            _buildNeoBox(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Grafik Peminjaman",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar(10, "Senin"),
                        _buildBar(30, "Selasa"),
                        _buildBar(20, "Rabu"),
                        _buildBar(40, "Kamis"),
                        _buildBar(50, "Jum'at"),
                        _buildBar(40, "Sabtu"),
                        _buildBar(20, "Minggu"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "( Peminjaman Selama 1 Minggu )",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// BOX KOSONG BAWAH
            _buildNeoBox(height: 160, child: const SizedBox.expand()),
            const SizedBox(height: 30),
          ],
        ),
      ),

      /// BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 2)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xff1B607A),
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: "Beranda"),
            BottomNavigationBarItem(icon: Icon(Icons.groups_sharp, size: 28), label: "Pengguna"),
            BottomNavigationBarItem(icon: Icon(Icons.computer, size: 28), label: "Alat"),
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined, size: 28), label: "Riwayat"),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined, size: 28), label: "Pengaturan"),
          ],
        ),
      ),
    );
  }

  /// REUSABLE NEO-BRUTALISM BOX (Kunci kemiripan gambar)
  Widget _buildNeoBox({required Widget child, double? height, EdgeInsets? padding}) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(4, 4), // Membuat bayangan tegas ke samping bawah
            blurRadius: 0, 
          ),
        ],
      ),
      child: child,
    );
  }

  /// WIDGET STATISTIK KECIL
  Widget _buildStatCard(String title, int value) {
    return _buildNeoBox(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.22, // Ukuran pas 3 kolom
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rectangle, size: 24, color: Colors.black),
                const SizedBox(width: 5),
                Text(
                  value.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// BAR GRAFIK HD
  Widget _buildBar(double value, String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: value * 2.2, // Skala tinggi
          width: 30,
          decoration: BoxDecoration(
            color: const Color(0xff1B607A),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}