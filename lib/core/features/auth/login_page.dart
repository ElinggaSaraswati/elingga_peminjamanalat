import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBD7FF), // biru muda sesuai gambar
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 80),

              // LOGO
              Image.asset(
                "assets/logo.png",
                height: 90,
              ),

              const SizedBox(height: 10),

              // TEKS APP
              const Text(
                "LabKomPINJAM",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 60),

              // EMAIL LABEL
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // EMAIL INPUT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(1, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.email),
                      hintText: "Masukkan Email Anda",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // SANDI LABEL
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sandi",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // PASSWORD INPUT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(1, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "Masukkan Sandi Anda",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      suffixIcon: IconButton(
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
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // BUTTON MASUK
              SizedBox(
                width: 100,
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                  onPressed: () {
                    print("Login ditekan");
                  },
                  child: const Text("Masuk"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
