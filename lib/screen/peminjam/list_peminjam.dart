import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PinjamPage extends StatefulWidget {
  const PinjamPage({super.key});

  @override
  State<PinjamPage> createState() => _PinjamPageState();
}

class _PinjamPageState extends State<PinjamPage> {
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
      case 'dikembalikan':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Cek apakah sudah ada pengembalian untuk peminjaman ini
  Future<bool> _sudahAdaPengembalian(int idPeminjaman) async {
    try {
      final res = await supabase
          .from('pengembalian')
          .select('id_pengembalian')
          .eq('id_peminjaman', idPeminjaman)
          .maybeSingle();
      return res != null && res.isNotEmpty;
    } catch (e) {
      print('Error cek pengembalian: $e');
      return false;
    }
  }

  Future<void> _ajukanPengembalian(int idPeminjaman, DateTime tglKembaliRencana) async {
    try {
      // Cek duplikat
      final sudahAda = await _sudahAdaPengembalian(idPeminjaman);
      if (sudahAda) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengembalian sudah diajukan sebelumnya'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final hariIni = DateTime.now();
      final tglKembali = DateTime(hariIni.year, hariIni.month, hariIni.day);

      int keterlambatan = 0;
      if (tglKembali.isAfter(tglKembaliRencana)) {
        keterlambatan = tglKembali.difference(tglKembaliRencana).inDays;
      }

      final data = {
        'id_peminjaman': idPeminjaman,
        'tanggal_kembali': tglKembali.toIso8601String().split('T')[0],
        'keterlambatan': keterlambatan,
        'denda': 0,
        'kondisi_alat': 'Menunggu verifikasi',
      };

      await supabase.from('pengembalian').insert(data);

      // Update status peminjaman jadi 'dikembalikan' (ini yang bikin tombol hilang & badge berubah)
      await supabase
          .from('peminjaman')
          .update({'status_peminjaman': 'dikembalikan'})
          .eq('id_peminjaman', idPeminjaman);

      if (!mounted) return;
      setState(() {}); // refresh UI → tombol hilang, status jadi 'dikembalikan'
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengembalian berhasil diajukan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error pengembalian: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengajukan pengembalian: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showKonfirmasiPengembalian(int idPeminjaman, DateTime tglKembaliRencana) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pengembalian'),
        content: const Text(
          'Apakah Anda yakin ingin mengembalikan alat ini sekarang?\n'
          'Petugas akan memverifikasi kondisi alat dan menghitung denda jika ada keterlambatan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _ajukanPengembalian(idPeminjaman, tglKembaliRencana);
            },
            child: const Text('Ya, Kembalikan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final greetingName = user?.email?.split('@')[0] ?? 'Peminjam';
    final userEmail = user?.email ?? 'Belum login';

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
          'Pinjam',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                    child: Icon(Icons.person, size: 32, color: Color(0xff1B607A)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, Selamat Datang $greetingName",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchPeminjaman(),
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
                        'Belum ada peminjaman',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final alat = item['alat'] as Map<String, dynamic>? ?? {};
                        final namaAlat = alat['nama_alat'] ?? 'Alat tidak diketahui';
                        final jumlah = item['jumlah_pinjam'] ?? 1;
                        final status = item['status_peminjaman'] ?? 'menunggu';
                        final tglPinjam = _formatDate(item['tanggal_pinjam']);
                        final tglKembali = _formatDate(item['tanggal_kembali_rencana']);
                        final idPeminjaman = item['id_peminjaman'] as int;

                        final bool bisaKembalikan = 
                            status.toLowerCase() == 'disetujui' || 
                            status.toLowerCase() == 'dipinjam';

                        final tglKembaliRencana = item['tanggal_kembali_rencana'] != null
                            ? DateTime.parse(item['tanggal_kembali_rencana'] as String)
                            : DateTime.now();

                        return _buildPeminjamanCard(
                          nama: namaAlat,
                          dateRange: '$tglPinjam - $tglKembali',
                          jumlah: jumlah,
                          status: status,
                          kategori: alat['kategori'],
                          idPeminjaman: idPeminjaman,
                          tglKembaliRencana: tglKembaliRencana,
                          bisaKembalikan: bisaKembalikan,
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

  Future<List<Map<String, dynamic>>> _fetchPeminjaman() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final userProfile = await supabase
        .from('users')
        .select('id_user')
        .eq('auth_id', user.id)
        .maybeSingle();

    if (userProfile == null || userProfile.isEmpty) {
      print('Profil user tidak ditemukan');
      return [];
    }

    final idUser = userProfile['id_user'] as int;

    final res = await supabase
        .from('peminjaman')
        .select('*, alat(*)')
        .eq('id_user', idUser)
        .order('tanggal_pinjam', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Widget _buildPeminjamanCard({
    required String nama,
    required String dateRange,
    required int jumlah,
    required String status,
    String? kategori,
    required int idPeminjaman,
    required DateTime tglKembaliRencana,
    required bool bisaKembalikan,
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xffE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(kategori),
                  size: 40,
                  color: const Color(0xff1B607A),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          dateRange,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xffE0F2FE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tersedia',
                            style: TextStyle(
                              color: Color(0xff0369A1),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total $jumlah alat',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),

          // Tombol Kembalikan hanya muncul kalau status masih disetujui/dipinjam
          if (bisaKembalikan) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showKonfirmasiPengembalian(idPeminjaman, tglKembaliRencana),
                icon: const Icon(Icons.assignment_return, size: 18),
                label: const Text('Kembalikan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(140, 40),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}