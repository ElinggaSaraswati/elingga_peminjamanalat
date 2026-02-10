import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final supabase = Supabase.instance.client;

  // Data dummy sesuai gambar di Supabase
  final List<Map<String, dynamic>> users = [
    {"name": "rizalputra", "email": "rizalputra@gmail.com", "role": "petugas", "status": "online"},
    {"name": "zalras", "email": "zalras@gmail.com", "role": "peminjam", "status": "offline"},
  ];

  // --- LOGIKA AKSI ---

  void _showDeleteDialog(String userName) {
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
                _buildDialogButton("Ya", Colors.green, () => Navigator.pop(context)),
                _buildDialogButton("Tidak", const Color(0xff8B0000), () => Navigator.pop(context)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _goToFormPage({bool isEdit = false, Map<String, dynamic>? userData}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormPage(isEdit: isEdit, userData: userData),
      ),
    );
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) => _buildUserCard(users[index]),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 25,
            child: GestureDetector(
              onTap: () => _goToFormPage(isEdit: false),
              child: _buildCircleButton(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

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
              Text(supabase.auth.currentUser?.email ?? "saraswatilingga@gmail.com", style: const TextStyle(color: Colors.black87)),
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
                Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(user['email'], style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(user['role'], style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    _buildStatusPill(user['status']),
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
                onTap: () => _showDeleteDialog(user['name']),
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
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2))],
      ),
      child: Icon(icon, size: 35, color: Colors.black),
    );
  }
}

// --- HALAMAN FORM (TAMBAH & EDIT) ---

class UserFormPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? userData;

  const UserFormPage({super.key, required this.isEdit, this.userData});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  String _selectedRole = "Peminjam";

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.userData != null) {
      _nameController.text = widget.userData!['name'];
      _emailController.text = widget.userData!['email'];
      _selectedRole = widget.userData!['role'].toString().capitalize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(widget.isEdit ? "Edit Pengguna" : "Tambah Pengguna Baru", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _buildProfileImage(),
            ),
            const SizedBox(height: 30),
            _buildFieldLabel("Nama"),
            _buildTextField(_nameController, "Masukkan nama anda"),
            _buildFieldLabel("Email"),
            _buildTextField(_emailController, "Masukkan email anda"),
            _buildFieldLabel("Sandi"),
            _buildTextField(_passwordController, "Masukkan sandi anda", isPassword: true),
            _buildFieldLabel("Jenis akun"),
            _buildDropdownField(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFormButton("Batal", Colors.white, Colors.black, () => Navigator.pop(context)),
                _buildFormButton(widget.isEdit ? "Simpan" : "Tambahkan Pengguna", 
                  const Color(0xff1B607A), Colors.white, () => Navigator.pop(context)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(widget.isEdit ? Icons.camera_alt : Icons.person_outline, size: 80, color: Colors.black),
        ),
        if (widget.isEdit)
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black)),
              child: const Icon(Icons.edit, size: 20),
            ),
          ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isPasswordObscured : false,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
              ) 
            : null,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedRole,
          items: ["Peminjam", "Petugas"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => _selectedRole = val!),
        ),
      ),
    );
  }

  Widget _buildFormButton(String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Helper untuk kapitalisasi kata pertama
extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}