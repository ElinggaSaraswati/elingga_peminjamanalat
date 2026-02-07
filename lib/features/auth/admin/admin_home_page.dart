import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

  final supabase = Supabase.instance.client;

  int totalAlat = 0;
  int totalDipinjam = 0;
  int totalTersedia = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final data = await supabase.from('alat').select();

    totalAlat = data.length;
    totalDipinjam =
        data.where((e) => e['status'] == 'Dipinjam').length;
    totalTersedia =
        data.where((e) => e['status'] == 'Tersedia').length;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xff9bb6d9),

      appBar: AppBar(
        title: const Text("Beranda Admin"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// HEADER USER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hi, Selamat Datang Admin",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(user?.email ?? "-"),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// CARD INFO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                infoCard("Total Alat", totalAlat),
                infoCard("Terpinjam", totalDipinjam),
                infoCard("Tersedia", totalTersedia),
              ],
            ),

            const SizedBox(height: 20),

            /// GRAFIK BOX
            Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    "Grafik Peminjaman",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Center(
                      child: Text("Grafik di sini (opsional chart nanti)"),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// BOX KOSONG
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Pengguna"),
          BottomNavigationBarItem(icon: Icon(Icons.laptop), label: "Alat"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
        ],
      ),
    );
  }

  Widget infoCard(String title, int value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3)
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.laptop),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12)),
          Text(
            value.toString(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
