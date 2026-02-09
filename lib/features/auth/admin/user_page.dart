import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final supabase = Supabase.instance.client;

  // Data dummy sesuai gambar
  final List<Map<String, dynamic>> users = [
    {
      "name": "rizalputra",
      "email": "rizalputra@gmail.com",
      "role": "Petugas",
      "status": "online",
    },
    {
      "name": "zalras",
      "email": "zalras@gmail.com",
      "role": "Peminjam",
      "status": "offline",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF), // Warna background biru muda
      appBar: AppBar(
        title: const Text(
          "Pengguna",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // 1. HEADER PROFIL ADMIN
                _buildNeoBox(
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
                            currentUser?.email ?? "saraswatilingga@gmail.com",
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. SEARCH BAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Cari pengguna",
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. DAFTAR USER
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(users[index]);
                  },
                ),
                const SizedBox(height: 100), // Ruang untuk tombol plus
              ],
            ),
          ),

          // 4. TOMBOL TAMBAH (Floating di kanan bawah)
          Positioned(
            bottom: 30,
            right: 25,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddUserPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, offset: Offset(2, 2))
                  ],
                ),
                child: const Icon(Icons.add, size: 35, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET KARTU USER
  Widget _buildUserCard(Map<String, dynamic> user) {
    bool isOnline = user['status'] == "online";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(3, 3), blurRadius: 2)
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.account_circle, size: 65, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(user['email'], style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(user['role'], style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    // Status Pill (Online/Offline)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Text(
                        user['status'],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tombol Aksi (Edit & Hapus)
          Column(
            children: [
              _buildActionButton(Icons.edit, "Edit", const Color(0xff1B607A)),
              const SizedBox(height: 8),
              _buildActionButton(Icons.delete, "Hapus", const Color(0xff8B0000)),
            ],
          )
        ],
      ),
    );
  }

  // WIDGET TOMBOL AKSI
  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // WIDGET KOTAK DASAR (Neo Box)
  Widget _buildNeoBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: child,
    );
  }
}

// Halaman Placeholder untuk Tambah User
class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Pengguna")),
      body: const Center(child: Text("Halaman Tambah Pengguna")),
    );
  }
}