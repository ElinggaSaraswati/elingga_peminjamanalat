import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_ukk/services/peminjam_service.dart'; // sesuaikan nama file service

class PengajuanPage extends StatefulWidget {
  final Map<String, dynamic> selectedAlat; // sekarang single Map, bukan List

  const PengajuanPage({
    super.key,
    required this.selectedAlat,
  });

  @override
  State<PengajuanPage> createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  DateTime? tanggalPinjam;
  DateTime? tanggalKembali;

  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      setState(() {
        _dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
      });
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    return _dateFormat.format(date);
  }

  Future<void> _selectDate(BuildContext context, bool isPinjam) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff1B607A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xff1B607A)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isPinjam) {
          tanggalPinjam = picked;
          if (tanggalKembali != null && tanggalKembali!.isBefore(picked)) {
            tanggalKembali = null;
          }
        } else {
          if (tanggalPinjam != null && picked.isBefore(tanggalPinjam!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tanggal kembali tidak boleh sebelum tanggal pinjam")),
            );
            return;
          }
          tanggalKembali = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final alat = widget.selectedAlat;
    final namaAlat = alat['nama_alat'] ?? 'Alat';
    final jumlah = alat['jumlah'] as int? ?? 1;
    final kategori = alat['kategori'] ?? alat['nama_kategori'] ?? '-';

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
          'Pengajuan Alat',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card alat (single)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xffE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.computer, size: 40, color: Color(0xff1B607A)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaAlat,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kategori: $kategori • Jumlah yang dipinjam: $jumlah',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tanggal Pinjam
              _buildSection('Tanggal Pinjam', Icons.calendar_today, _formatDate(tanggalPinjam),
                  () => _selectDate(context, true), true),

              const SizedBox(height: 16),

              // Tanggal Kembali
              _buildSection('Tanggal Kembali', Icons.event_available, _formatDate(tanggalKembali),
                  tanggalPinjam != null ? () => _selectDate(context, false) : null, tanggalPinjam != null),

              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    Text(
                      'Jumlah alat: $jumlah',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (tanggalPinjam != null && tanggalKembali != null)
                            ? () async {
                                final service = PeminjamanService();
                                final success = await service.ajukanPeminjaman(
                                  alat: alat,
                                  tanggalPinjam: tanggalPinjam!,
                                  tanggalKembali: tanggalKembali!,
                                );

                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Pengajuan berhasil dikirim! Status: Menunggu')),
                                  );
                                  Navigator.pop(context, true);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gagal mengajukan peminjaman')),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1B607A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Kirim Pengajuan',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, String label, VoidCallback? onTap, bool enabled) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1B607A)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: enabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: enabled ? const Color(0xffF0F7FF) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: enabled ? const Color(0xff1B607A) : Colors.grey[400]!),
              ),
              child: Row(
                children: [
                  Icon(icon, color: enabled ? const Color(0xff1B607A) : Colors.grey, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 15, color: enabled ? Colors.black87 : Colors.grey[600]),
                    ),
                  ),
                  if (enabled) const Icon(Icons.arrow_drop_down, color: Color(0xff1B607A)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}