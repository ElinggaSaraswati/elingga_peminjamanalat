import 'package:flutter/material.dart';
import 'package:project_ukk/services/kategori_service.dart';

class KategoriAddPage extends StatefulWidget {
  final bool isEdit;
  final int? idKategori;
  final String? namaKategori;

  const KategoriAddPage({
    super.key,
    this.isEdit = false,
    this.idKategori,
    this.namaKategori,
  });

  @override
  State<KategoriAddPage> createState() => _KategoriAddPageState();
}

class _KategoriAddPageState extends State<KategoriAddPage> {
  final kategoriService = KategoriService();
  final TextEditingController namaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      namaController.text = widget.namaKategori ?? '';
    }
  }

  Future<void> simpan() async {
    final nama = namaController.text.trim();

    if (nama.isEmpty) return;

    if (widget.isEdit) {
      await kategoriService.updateKategori(widget.idKategori!, nama);
    } else {
      await kategoriService.tambahKategori(nama);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? "Edit Kategori" : "Tambah Kategori Baru",
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Nama Kategori"),
            _textfield("Masukkan nama kategori"),
        
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1B607A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  widget.isEdit
                      ? "SIMPAN PERUBAHAN"
                      : "TAMBAHKAN KATEGORI",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _textfield(String hint) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black),
        ),
        child: TextField(
          controller: namaController,
          decoration: InputDecoration(hintText: hint, border: InputBorder.none),
        ),
      );
}
