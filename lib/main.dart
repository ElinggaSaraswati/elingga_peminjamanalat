import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/login_page.dart';

// ================= SUPABASE CONFIG =================
const supabaseUrl = 'https://rezbnvoprehlynhybknc.supabase.co';
const supabaseKey = 'sb_publishable_pEFiqlDJXCp261e7jFzeBQ_46EMcQf3';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const MyApp());
}

// ================= ROOT APP =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // ⬅️ HANYA LOGIN PAGE
    );
  }
}






// ===================================================
// MODEL ALAT (TIDAK DIHAPUS, TETAP TERHUBUNG SUPABASE)
// ===================================================
class Alat {
  final int id;
  final String namaAlat;
  final String kondisi;
  final int jumlah;
  final String status;

  Alat({
    required this.id,
    required this.namaAlat,
    required this.kondisi,
    required this.jumlah,
    required this.status,
  });

  factory Alat.fromMap(Map<String, dynamic> map) {
    return Alat(
      id: map['id_alat'],
      namaAlat: map['nama_alat'] ?? '',
      kondisi: map['kondisi'] ?? '',
      jumlah: map['jumlah'] ?? 0,
      status: map['status'] ?? '',
    );
  }
}







// ===================================================
// HALAMAN LIST ALAT
// TIDAK DIPANGGIL OTOMATIS LAGI
// HANYA AKAN DIPANGGIL JIKA ANDA NAVIGATE MANUAL
// ===================================================
class AlatListPage extends StatefulWidget {
  const AlatListPage({super.key});

  @override
  State<AlatListPage> createState() => _AlatListPageState();
}

class _AlatListPageState extends State<AlatListPage> {
  final Stream<List<Map<String, dynamic>>> _alatStream =
      Supabase.instance.client.from('alat').stream(primaryKey: ['id_alat']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Alat Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _alatStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data alat'));
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = Alat.fromMap(data[index]);

              return ListTile(
                title: Text(item.namaAlat),
                subtitle: Text("Stok: ${item.jumlah}"),
              );
            },
          );
        },
      ),
    );
  }
}
