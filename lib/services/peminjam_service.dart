import 'package:supabase_flutter/supabase_flutter.dart';

class PeminjamanService {
  final supabase = Supabase.instance.client;

  Future<int?> getCurrentUserId() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('users')
        .select('id_user')
        .eq('auth_id', user.id)
        .maybeSingle();

    return response?['id_user'] as int?;
  }

  Future<bool> ajukanPeminjaman({
    required Map<String, dynamic> alat,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      print('User tidak login');
      return false;
    }

    final idAlat = alat['id_alat'] as int?;
    if (idAlat == null) {
      print('ID alat tidak ditemukan');
      return false;
    }

    final jumlahPinjam = alat['jumlah'] as int? ?? 1;

    final data = {
      'id_user': userId,
      'id_alat': idAlat,
      'tanggal_pinjam': tanggalPinjam.toIso8601String().split('T')[0],
      'tanggal_kembali_rencana': tanggalKembali.toIso8601String().split('T')[0],
      'status_peminjaman': 'menunggu',
      'jumlah_pinjam': jumlahPinjam,  
    };

    try {
      await supabase.from('peminjaman').insert(data);
      print('Pengajuan berhasil: $data');
      return true;
    } catch (e) {
      print('Error ajukan peminjaman: $e');
      return false;
    }
  }
}