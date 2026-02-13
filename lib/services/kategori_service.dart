import 'package:supabase_flutter/supabase_flutter.dart';

class KategoriService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getKategori() async {
    final data = await supabase
        .from('kategori')
        .select()
        .order('id_kategori');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> tambahKategori(String nama) async {
    await supabase.from('kategori').insert({
      'nama_kategori': nama,
    });
  }

  Future<void> updateKategori(int id, String nama) async {
    await supabase.from('kategori').update({
      'nama_kategori': nama,
    }).eq('id_kategori', id);
  }

  Future<void> deleteKategori(int id) async {
    await supabase.from('kategori').delete().eq('id_kategori', id);
  }
}
