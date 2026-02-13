import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PetugasPinjamPage extends StatefulWidget {
  const PetugasPinjamPage({super.key});

  @override
  State<PetugasPinjamPage> createState() => _PetugasPinjamPageState();
}

class _PetugasPinjamPageState extends State<PetugasPinjamPage> {
  final supabase = Supabase.instance.client;
  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      setState(() {
        _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
      });
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    final dt = date is String ? DateTime.parse(date) : date as DateTime;
    return _dateFormat.format(dt);
  }

  IconData _getIcon(String? kategori) {
    final kat = kategori?.toLowerCase() ?? '';
    if (kat.contains('laptop')) return Icons.laptop;
    if (kat.contains('mouse')) return Icons.mouse;
    if (kat.contains('kamera')) return Icons.camera_alt;
    if (kat.contains('proyektor')) return Icons.videocam;
    return Icons.devices;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange;
      case 'disetujui':
      case 'dipinjam':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'dikembalikan':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 110),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Future<void> _updateStatus(int idPeminjaman, String newStatus) async {
    try {
      await supabase
          .from('peminjaman')
          .update({'status_peminjaman': newStatus})
          .eq('id_peminjaman', idPeminjaman);

      if (newStatus == 'disetujui') {
        // Optional: update status alat jadi 'Dipinjam' (uncomment kalau perlu)
        // final peminjaman = await supabase.from('peminjaman').select('id_alat').eq('id_peminjaman', idPeminjaman).single();
        // await supabase.from('alat').update({'status': 'Dipinjam'}).eq('id_alat', peminjaman['id_alat']);
      }

      setState(() {}); // refresh list
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah menjadi $newStatus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Peminjaman - Petugas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xffE8F0FE),
                    child: Icon(Icons.security, size: 32, color: Color(0xff1B607A)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Dashboard Petugas",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Kelola persetujuan peminjaman",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Daftar peminjaman
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAllPeminjaman(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final list = snapshot.data ?? [];
                  
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada pengajuan peminjaman',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final alat = item['alat'] as Map<String, dynamic>? ?? {};
                        final user = item['users'] as Map<String, dynamic>? ?? {};
                        final namaAlat = alat['nama_alat'] ?? 'Alat tidak diketahui';
                        final namaUser = user['nama'] ?? user['username'] ?? 'User tidak diketahui';
                        final jumlah = item['jumlah_pinjam'] as int? ?? 1;
                        final status = (item['status_peminjaman'] ?? 'menunggu').toString().toLowerCase();
                        final tglPinjam = _formatDate(item['tanggal_pinjam']);
                        final tglKembali = _formatDate(item['tanggal_kembali_rencana']);

                        return _buildPeminjamanCard(
                          namaAlat: namaAlat,
                          namaPeminjam: namaUser,
                          dateRange: '$tglPinjam - $tglKembali',
                          jumlah: jumlah,
                          status: status,
                          kategori: alat['kategori']?['nama_kategori'] as String?,
                          idPeminjaman: item['id_peminjaman'] as int,
                          canAction: status == 'menunggu',
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllPeminjaman() async {
  final res = await supabase
      .from('peminjaman')
      .select('''
        id_peminjaman,
        tanggal_pinjam,
        tanggal_kembali_rencana,
        status_peminjaman,
        jumlah_pinjam,
        alat:alat (
          id_alat,
          nama_alat,
          kategori:kategori (
            nama_kategori
          )
        ),
        users:users (
          nama,
          username
        )
      ''')
      .order('id_peminjaman', ascending: false);

  print(res); // 🔥 LIHAT DI CONSOLE
  return List<Map<String, dynamic>>.from(res);
}


  Widget _buildPeminjamanCard({
    required String namaAlat,
    required String namaPeminjam,
    required String dateRange,
    required int jumlah,
    required String status,
    String? kategori,
    required int idPeminjaman,
    required bool canAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama peminjam
          Text(
            namaPeminjam,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff1B607A),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),

          // Nama alat yang diminta
          Text(
            'Meminta: $namaAlat',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),

          const SizedBox(height: 12),

          // Bagian tengah: icon + info + badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xffE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(_getIcon(kategori), size: 36, color: const Color(0xff1B607A)),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            dateRange,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Jumlah: $jumlah alat',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              _buildStatusBadge(status),
            ],
          ),

          // Tombol action (hanya muncul kalau menunggu)
          if (canAction) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _updateStatus(idPeminjaman, 'ditolak'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(90, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Tolak', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _updateStatus(idPeminjaman, 'disetujui'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(90, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Setujui',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}