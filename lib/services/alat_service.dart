import 'package:supabase_flutter/supabase_flutter.dart';

class AlatService {
  final supabase = Supabase.instance.client;

  /// GET semua alat + join kategori
  Future<List<Map<String, dynamic>>> getAlat() async {
    final response = await supabase
        .from('alat')
        .select('''
          id_alat,
          nama_alat,
          jumlah,
          status,
          gambar,
          kategori(id_kategori, nama_kategori)
        ''')
        .order('id_alat', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// TAMBAH alat
  Future<void> tambahAlat({
    required String nama,
    required int kategoriId,
    required int jumlah,
    String? gambar,
  }) async {
    await supabase.from('alat').insert({
      'nama_alat': nama,
      'id_kategori': kategoriId,
      'jumlah': jumlah,
      'gambar': gambar,
    });
  }

  /// DELETE alat
  Future<void> deleteAlat(int id) async {
    await supabase.from('alat').delete().eq('id_alat', id);
  }

  /// UPDATE alat
  Future<void> updateAlat({
    required int id,
    required String nama,
    required int kategoriId,
    required int jumlah,
    String? gambar,
  }) async {
    await supabase.from('alat').update({
      'nama_alat': nama,
      'id_kategori': kategoriId,
      'jumlah': jumlah,
      'gambar': gambar,
    }).eq('id_alat', id);
  }
}
