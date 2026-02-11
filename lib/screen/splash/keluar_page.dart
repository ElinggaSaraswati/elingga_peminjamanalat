import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 4; // Index 4 untuk Pengaturan

  // Controller untuk mengisi data otomatis dari database
  final TextEditingController _namaController = TextEditingController(text: "Elingga Saraswati");
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sandiController = TextEditingController(text: "saraswati61107");
  final TextEditingController _roleController = TextEditingController(text: "Admin");

  @override
  void initState() {
    super.initState();
    // Mengambil email dari auth session
    _emailController.text = supabase.auth.currentUser?.email ?? "saraswatilingga@gmail.com";
  }

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF), // Background biru muda sesuai desain
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pengaturan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            // Memberikan jarak atas sebagai pengganti logo yang dihapus
            const SizedBox(height: 40),

            // Form Fields
            _buildInputField("Nama", _namaController),
            _buildInputField("Email", _emailController),
            _buildInputField("Sandi", _sandiController, isPassword: true),
            _buildInputField("Sebagai", _roleController),

            const SizedBox(height: 30),

            // Tombol Keluar
            GestureDetector(
              onTap: _handleLogout,
              child: Container(
                width: 140,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Keluar",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
      
      // Bottom Navigation Bar sesuai desain gambar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xff1B607A),
          unselectedItemColor: Colors.black,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Beranda"),
            BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: "Pengguna"),
            BottomNavigationBarItem(icon: Icon(Icons.laptop_chromebook), label: "Alat"),
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: "Riwayat"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [
                BoxShadow(color: Colors.black26, offset: Offset(0, 4)),
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}