import 'package:flutter/material.dart';
import './admin/admin_home_page.dart'; // ⬅️ IMPORT BENAR

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // LANGSUNG KE BERANDA ADMIN
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBD7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 80),

                const Icon(
                  Icons.inventory_2_rounded,
                  size: 90,
                  color: Colors.blueAccent,
                ),

                const SizedBox(height: 10),
                const Text(
                  "LabKomPINJAM",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 60),

                _buildLabel("Email"),
                _buildInput(
                  controller: _emailController,
                  hint: "Masukkan Email Anda",
                  icon: Icons.email,
                ),

                const SizedBox(height: 25),

                _buildLabel("Sandi"),
                _buildInput(
                  controller: _passwordController,
                  hint: "Masukkan Sandi Anda",
                  icon: Icons.lock,
                  isPassword: true,
                ),

                const SizedBox(height: 50),

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
                    onPressed: _login,
                    child: const Text(
                      "Masuk",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
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
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(icon, size: 20),
            hintText: hint,
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
