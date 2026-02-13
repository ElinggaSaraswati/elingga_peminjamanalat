import 'package:flutter/material.dart';
import 'alat_page_pinjam.dart';
import 'list_peminjam.dart';
import 'package:project_ukk/screen/splash/keluar_page.dart';

class PeminjamHomePage extends StatefulWidget {
  const PeminjamHomePage({super.key});

  @override
  State<PeminjamHomePage> createState() => _PeminjamHomePageState();
}

class _PeminjamHomePageState extends State<PeminjamHomePage> {
  int _currentIndex = 0;

  // List halaman untuk navigasi
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildBerandaContent(), 
      const AlatPage(role: 'peminjam'), 
      const  PinjamPage(),
      const Center(child: Text("Halaman Kembali")),
      const PengaturanPage(), 
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3D1FF),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.black87,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.laptop), label: 'Alat'),
            BottomNavigationBarItem(icon: Icon(Icons.download_rounded), label: 'Pinjam'),
            BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Kembali'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
          ],
        ),
      ),
    );
  }

  // Konten Utama Beranda
  Widget _buildBerandaContent() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black12,
                  child: Icon(Icons.person, size: 40, color: Colors.black),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi, Selamat Datang zalras',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('zalras@gmail.com', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.4,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMenuCard('Laptop', Icons.laptop_mac),
                _buildMenuCard('Mouse', Icons.mouse),
                _buildMenuCard('Camera', Icons.camera_alt),
                _buildMenuCard('Proyektor', Icons.videocam),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                ],
              ),
              child: const Center(child: Text("Informasi Peminjaman Terkini")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon) {
    return GestureDetector(
      onTap: () => _onTabTapped(1), // Saat kartu ditekan, pindah ke index Alat (1)
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Icon(icon, size: 50),
          ],
        ),
      ),
    );
  }
}