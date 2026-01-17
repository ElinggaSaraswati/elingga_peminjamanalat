import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// REKOMENDASI: Ganti URL dan KEY ini dengan milik project Supabase Anda
const supabaseUrl = 'https://rezbnvoprehlynhybknc.supabase.co';
const supabaseKey = 'sb_publishable_pEFiqlDJXCp261e7jFzeBQ_46EMcQf3';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Peminjaman Alat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AlatListPage(),
    );
  }
}

// Model Data berdasarkan Tabel 'alat' di Gambar Anda
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

  // Map dari Database ke Object Flutter
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

class AlatListPage extends StatefulWidget {
  const AlatListPage({super.key});

  @override
  State<AlatListPage> createState() => _AlatListPageState();
}

class _AlatListPageState extends State<AlatListPage> {
  // Logic untuk mengambil data dari tabel 'alat'
  final Stream<List<Map<String, dynamic>>> _alatStream =
      Supabase.instance.client.from('alat').stream(primaryKey: ['id_alat']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Alat Inventory'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _alatStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Tidak ada data alat.'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = Alat.fromMap(data[index]);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.handyman),
                  title: Text(item.namaAlat, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Kondisi: ${item.kondisi} | Stok: ${item.jumlah}'),
                  trailing: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: item.status == 'Tersedia' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logika untuk menambah peminjaman bisa diletakkan di sini
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Tambah Peminjaman akan muncul di sini')),
          );
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}