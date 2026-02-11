import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_add_edit.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final supabase = Supabase.instance.client;

  final Stream<List<Map<String, dynamic>>> _userStream =
      Supabase.instance.client.from('users').stream(primaryKey: ['id_user']);

  Future<void> _deleteUser(int id) async {
    try {
      await supabase.from('users').delete().eq('id_user', id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: $e")),
      );
    }
  }

  void _showDeleteDialog(String userName, int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Hapus", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("apakah anda yakin menghapus pengguna $userName ini", textAlign: TextAlign.center),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDialogButton("Ya", Colors.green, () => _deleteUser(userId)),
                _buildDialogButton("Tidak", const Color(0xff8B0000), () => Navigator.pop(context)),
              ],
            )
          ],
        ),
      ),
    );
  }

void _goToFormPage({bool isEdit = false, Map<String, dynamic>? userData}) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => UserFormPage(isEdit: isEdit, userData: userData),
    ),
  );

  if (result == true && mounted) {
    setState(() {}); 
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF),
      appBar: AppBar(
        title: const Text("Pengguna", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                _buildAdminHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _userStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Tidak ada pengguna di database"));
                    }
                    
                    final usersData = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: usersData.length,
                      itemBuilder: (context, index) {
                        return _buildUserCard(usersData[index]);
                      },
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(bottom: 30, right: 25,
            child: GestureDetector(
              onTap: () => _goToFormPage(isEdit: false),
              child: _buildCircleButton(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildAdminHeader() {
    return Container(
      width: double.infinity,
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
              const Text("Hi, Selamat Datang Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(supabase.auth.currentUser?.email ?? "admin@email.com", style: const TextStyle(color: Colors.black87)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
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
          const Icon(Icons.account_circle, size: 65, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(user['username'] ?? '-', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(user['role'] ?? '-', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    _buildStatusPill("aktif"),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => _goToFormPage(isEdit: true, userData: user),
                child: _buildActionButton(Icons.edit, "Edit", const Color(0xff1B607A)),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showDeleteDialog(user['nama'] ?? 'User', user['id_user']),
                child: _buildActionButton(Icons.delete, "Hapus", const Color(0xff8B0000)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Text(status, style: const TextStyle(fontSize: 10)),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDialogButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
        child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }

 Widget _buildCircleButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle, 
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2))
        ],
      ),
      child: Icon(icon, size: 35, color: Colors.black),
    );
  }
}