import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserFormPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? userData;

  const UserFormPage({super.key, required this.isEdit, this.userData});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String _selectedRole = "peminjam";

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.userData != null) {
      _nameController.text = widget.userData!['nama'] ?? '';
      _emailController.text = widget.userData!['username'] ?? '';
      _selectedRole = (widget.userData!['role'] ?? 'peminjam').toString().toLowerCase();
    }
  }

  Future<void> _handleSave() async {
  // 1. Validasi awal
  if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nama dan Email wajib diisi")),
    );
    return;
  }

  // Validasi password khusus untuk user baru
  if (!widget.isEdit && _passwordController.text.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sandi minimal harus 6 karakter")),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    if (widget.isEdit) {
      // LOGIKA EDIT: Langsung update tabel users
      await supabase.from('users').update({
        'nama': _nameController.text.trim(),
        'username': _emailController.text.trim(),
        'role': _selectedRole,
      }).eq('id_user', widget.userData!['id_user']);
      
    } else {
      // LOGIKA TAMBAH BARU: Auth dulu baru Database
      // Gunakan signUp untuk mendaftarkan akun ke Supabase Auth
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;

      if (user != null) {
        // Masukkan data ke tabel profil kita (users)
        await supabase.from('users').insert({
          'auth_id': user.id, 
          'nama': _nameController.text.trim(),
          'username': _emailController.text.trim(),
          'role': _selectedRole,
        });
      }
    }

    if (mounted) {
      // Kembali ke halaman sebelumnya dan kirim sinyal sukses
      Navigator.pop(context, true); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? "Berhasil diperbarui" : "Pengguna ditambahkan"),
          backgroundColor: Colors.green,
        ),
      );
    }
  } on AuthException catch (e) {
    // Menangkap error khusus dari Supabase Auth (misal: Email sudah ada)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Auth Error: ${e.message}"), backgroundColor: Colors.red),
    );
  } catch (e) {
    // Menangkap error umum lainnya
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
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
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildProfileImage()),
            const SizedBox(height: 30),
            _buildFieldLabel("Nama"),
            _buildTextField(_nameController, "Masukkan nama anda"),
            _buildFieldLabel("Email/Username"),
            _buildTextField(_emailController, "Masukkan email anda"),
            if (!widget.isEdit) ...[
              _buildFieldLabel("Sandi"),
              _buildTextField(_passwordController, "Masukkan sandi anda", isPassword: true),
            ],
            _buildFieldLabel("Jenis akun"),
            _buildDropdownField(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFormButton("Batal", Colors.white, Colors.black, () => Navigator.pop(context)),
                _buildFormButton(widget.isEdit ? "Simpan" : "Tambahkan Pengguna", 
                  const Color(0xff1B607A), Colors.white, _handleSave),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildProfileImage() {
    return Container(
      width: 150, height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Icon(widget.isEdit ? Icons.person_outline : Icons.person_outline, size: 80, color: Colors.black),
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
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
              ) : null,
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
          items: ["peminjam", "petugas", "admin"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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