import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Pastikan sudah install package ini
import './admin/admin_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false; // Status loading

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fungsi Login dengan Supabase
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi Input Sederhana
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Email dan sandi tidak boleh kosong", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Proses Sign In ke Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        if (!mounted) return;
        
        // Login Berhasil
        _showSnackBar("Login Berhasil!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomePage()),
        );
      }
    } on AuthException catch (error) {
      // Tangkap error spesifik dari Supabase (misal: user not found / wrong password)
      _showSnackBar(error.message, isError: true);
    } catch (error) {
      // Tangkap error lainnya
      _showSnackBar("Terjadi kesalahan yang tidak terduga", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi pembantu untuk menampilkan pesan
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBD7FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                /// LOGO
                Container(
                  height: 140,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 170,
                    height: 170,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 10),

                _buildLabel("Email"),
                _buildInput(
                  controller: _emailController,
                  hint: "Masukkan Email Anda",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 18),

                _buildLabel("Sandi"),
                _buildInput(
                  controller: _passwordController,
                  hint: "Masukkan Sandi Anda",
                  icon: Icons.lock,
                  isPassword: true,
                ),

                const SizedBox(height: 30),

                // TOMBOL LOGIN
                SizedBox(
                  width: 150,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 3,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Disable klik jika sedang loading
                    onPressed: _isLoading ? null : _login, 
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                        )
                      : const Text(
                          "Masuk",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(icon, size: 20),
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}