import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PetugasPengembalianPage extends StatefulWidget {
  const PetugasPengembalianPage({super.key});

  @override
  State<PetugasPengembalianPage> createState() => _PetugasPengembalianPageState();
}

class _PetugasPengembalianPageState extends State<PetugasPengembalianPage> {
  final supabase = Supabase.instance.client;
  late final DateFormat _dateFormat;
  late final NumberFormat _currencyFormat;

  final int tarifDendaPerHari = 10000;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      setState(() {
        _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
        _currencyFormat = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );
      });
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    final dt = date is String ? DateTime.parse(date) : date as DateTime;
    return _dateFormat.format(dt);
  }

  String _formatCurrency(int? value) {
    if (value == null || value <= 0) return '-';
    return _currencyFormat.format(value);
  }

  IconData _getIcon(String? kategori) {
    final kat = kategori?.toLowerCase() ?? '';
    if (kat.contains('laptop')) return Icons.laptop;
    if (kat.contains('mouse')) return Icons.mouse;
    if (kat.contains('kamera')) return Icons.camera_alt;
    if (kat.contains('proyektor')) return Icons.videocam;
    return Icons.devices;
  }

  Color _getStatusColor(String kondisi) {
    switch (kondisi.toLowerCase()) {
      case 'baik':
        return Colors.green;
      case 'rusak ringan':
      case 'rusak sedang':
        return Colors.orange;
      case 'rusak berat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildKondisiBadge(String kondisi) {
    final color = _getStatusColor(kondisi);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          kondisi.toUpperCase(),
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

 Future<void> _verifikasiPengembalian(
  int idPengembalian,
  String kondisi,
  int denda,
) async {
  try {
    // Update kondisi dan denda di pengembalian
    await supabase
        .from('pengembalian')
        .update({'kondisi_alat': kondisi, 'denda': denda})
        .eq('id_pengembalian', idPengembalian);

    // Ambil id_peminjaman
    final pengembalian = await supabase
        .from('pengembalian')
        .select('id_peminjaman')
        .eq('id_pengembalian', idPengembalian)
        .single();

    // Ambil id_alat
    final peminjaman = await supabase
        .from('peminjaman')
        .select('id_alat')
        .eq('id_peminjaman', pengembalian['id_peminjaman'])
        .single();

    // Update status alat jadi 'Tersedia'
    await supabase
        .from('alat')
        .update({'status': 'Tersedia'})
        .eq('id_alat', peminjaman['id_alat']);

    // Ambil id_user integer
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User tidak terautentikasi');
    }

    final userProfile = await supabase
        .from('users')
        .select('id_user')
        .eq('auth_id', user.id)
        .maybeSingle();

    if (userProfile == null || userProfile.isEmpty) {
      throw Exception('Profil user tidak ditemukan');
    }

    final idUserInteger = userProfile['id_user'] as int;

    // Data log dengan tanggal sebagai string ISO
    final logData = {
      'id_user': idUserInteger,
      'aktivitas': 'Verifikasi pengembalian #$idPengembalian - Kondisi: $kondisi - Denda: ${_formatCurrency(denda)}',
      'tanggal': DateTime.now().toIso8601String(),  // ← FIX DISINI
    };

    print('Data log yang akan diinsert: $logData');

    await supabase.from('log_aktivitas').insert(logData);

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengembalian berhasil diverifikasi'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print('=== ERROR VERIFIKASI & LOG ===');
    print('Error: $e');
    if (e is PostgrestException) {
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal verifikasi: $e'), backgroundColor: Colors.red),
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
          'Pengembalian - Petugas',
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
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xffE8F0FE),
                    child: Icon(Icons.assignment_return, size: 32, color: Color(0xff1B607A)),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kelola Pengembalian",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Verifikasi kondisi & denda jika rusak",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAllPengembalian(),
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
                      child: Text('Belum ada pengembalian', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final peminjaman = item['peminjaman'] as Map<String, dynamic>? ?? {};
                        final alat = peminjaman['alat'] as Map<String, dynamic>? ?? {};
                        final user = peminjaman['users'] as Map<String, dynamic>? ?? {};

                        final namaAlat = alat['nama_alat'] ?? 'Alat tidak diketahui';
                        final namaUser = user['nama'] ?? user['username'] ?? 'User tidak diketahui';
                        final tglKembali = _formatDate(item['tanggal_kembali']);
                        final keterlambatan = item['keterlambatan'] as int? ?? 0;
                        final kondisi = item['kondisi_alat'] ?? 'Belum diverifikasi';
                        final denda = item['denda'] as int? ?? 0;
                        final idPengembalian = item['id_pengembalian'] as int;

                        final sudahDiverifikasi = kondisi != 'Belum diverifikasi' &&
                            kondisi != null &&
                            kondisi != '' &&
                            kondisi.toLowerCase() != 'menunggu verifikasi';

                        return _buildPengembalianCard(
                          namaAlat: namaAlat,
                          namaPeminjam: namaUser,
                          tglKembali: tglKembali,
                          keterlambatan: keterlambatan,
                          kondisi: kondisi,
                          denda: denda,
                          kategori: alat['kategori']?['nama_kategori'] as String?,
                          idPengembalian: idPengembalian,
                          sudahDiverifikasi: sudahDiverifikasi,
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

  Future<List<Map<String, dynamic>>> _fetchAllPengembalian() async {
    final res = await supabase
        .from('pengembalian')
        .select('''
          *,
          denda,
          peminjaman!inner(
            *,
            alat(*, kategori(nama_kategori)),
            users(nama, username)
          )
        ''')
        .order('tanggal_kembali', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Widget _buildPengembalianCard({
    required String namaAlat,
    required String namaPeminjam,
    required String tglKembali,
    required int keterlambatan,
    required String kondisi,
    required int denda,
    String? kategori,
    required int idPengembalian,
    required bool sudahDiverifikasi,
  }) {
    final dendaTelatSaran = keterlambatan * tarifDendaPerHari;

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
          Text(
            'Mengembalikan: $namaAlat',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),

          const SizedBox(height: 12),

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
                            'Kembali: $tglKembali',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Keterlambatan: ${keterlambatan > 0 ? "$keterlambatan hari" : "Tepat waktu"}',
                      style: TextStyle(
                        fontSize: 13,
                        color: keterlambatan > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                    if (denda > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.money, size: 16, color: Colors.red),
                          const SizedBox(width: 6),
                          Text(
                            'Denda: ${_formatCurrency(denda)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),
              _buildKondisiBadge(kondisi),
            ],
          ),

          if (!sudahDiverifikasi) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final TextEditingController dendaController = TextEditingController(
                      text: dendaTelatSaran > 0 ? dendaTelatSaran.toString() : '0',
                    );

                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        String selectedKondisi = 'Baik';

                        return StatefulBuilder(
                          builder: (context, setDialogState) => AlertDialog(
                            title: const Text('Verifikasi Pengembalian'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Kondisi alat:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),

                                RadioListTile<String>(
                                  title: const Text('Baik'),
                                  value: 'Baik',
                                  groupValue: selectedKondisi,
                                  onChanged: (value) {
                                    setDialogState(() => selectedKondisi = value!);
                                  },
                                ),
                                RadioListTile<String>(
                                  title: const Text('Rusak Ringan'),
                                  value: 'Rusak Ringan',
                                  groupValue: selectedKondisi,
                                  onChanged: (value) {
                                    setDialogState(() => selectedKondisi = value!);
                                  },
                                ),
                                RadioListTile<String>(
                                  title: const Text('Rusak Berat'),
                                  value: 'Rusak Berat',
                                  groupValue: selectedKondisi,
                                  onChanged: (value) {
                                    setDialogState(() => selectedKondisi = value!);
                                  },
                                ),

                                const Divider(height: 24),

                                if (selectedKondisi != 'Baik') ...[
                                  TextField(
                                    controller: dendaController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Nominal Denda (Rp)',
                                      prefixText: 'Rp ',
                                      border: const OutlineInputBorder(),
                                      helperText: keterlambatan > 0
                                          ? 'Saran denda telat: ${_formatCurrency(dendaTelatSaran)}'
                                          : 'Masukkan nominal denda kerusakan',
                                      helperStyle: const TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Kondisi Baik → Denda: Rp 0',
                                    style: TextStyle(color: Colors.green[700]),
                                  ),
                                ],
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final denda = selectedKondisi == 'Baik'
                                      ? 0
                                      : (int.tryParse(dendaController.text.trim()) ?? 0);

                                  Navigator.pop(dialogContext);
                                  _verifikasiPengembalian(idPengembalian, selectedKondisi, denda);
                                },
                                child: const Text('Verifikasi'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Verifikasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1B607A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(160, 40),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Sudah diverifikasi',
                style: TextStyle(fontSize: 12, color: Colors.green[700]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}