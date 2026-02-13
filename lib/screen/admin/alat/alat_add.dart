import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatAddPage extends StatefulWidget {
  final Map<String, dynamic>? data; // kalau edit

  const AlatAddPage({super.key, this.data});

  @override
  State<AlatAddPage> createState() => _AlatAddPageState();
}

class _AlatAddPageState extends State<AlatAddPage> {
  final supabase = Supabase.instance.client;

  final namaController = TextEditingController();
  final stokController = TextEditingController();

  String? tempStatus;
  int? kategoriId;
  String? imageUrl;
  File? imageFile;

  List<Map<String, dynamic>> kategoriList = [];

  bool get isEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    loadKategori();

    if (isEdit) {
      namaController.text = widget.data!['nama_alat'] ?? '';
      stokController.text = widget.data!['jumlah'].toString();
      tempStatus = widget.data!['status'];
      kategoriId = widget.data!['id_kategori'];
      imageUrl = widget.data!['gambar'];
    }
  }

  /// =========================
  /// LOAD KATEGORI
  /// =========================
  Future<void> loadKategori() async {
    final res = await supabase.from('kategori').select();
    setState(() {
      kategoriList = List<Map<String, dynamic>>.from(res);
    });
  }

  /// =========================
  /// PICK IMAGE
  /// =========================
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  /// =========================
  /// UPLOAD IMAGE
  /// =========================
  Future<String?> uploadImage() async {
    if (imageFile == null) return imageUrl;

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    await supabase.storage
        .from('asset_ukk')
        .upload('alat/$fileName.jpg', imageFile!);

    final url =
        supabase.storage.from('asset_ukk').getPublicUrl('alat/$fileName.jpg');

    return url;
  }

  /// =========================
  /// SIMPAN DATA
  /// =========================
  Future<void> simpan() async {
    final nama = namaController.text;
    final stok = int.tryParse(stokController.text) ?? 0;

    if (nama.isEmpty || kategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data")),
      );
      return;
    }

    final uploadedImage = await uploadImage();

    if (isEdit) {
      await supabase.from('alat').update({
        'nama_alat': nama,
        'id_kategori': kategoriId,
        'jumlah': stok,
        'status': tempStatus ?? 'Tersedia',
        'gambar': uploadedImage,
      }).eq('id_alat', widget.data!['id_alat']);
    } else {
      await supabase.from('alat').insert({
        'nama_alat': nama,
        'id_kategori': kategoriId,
        'jumlah': stok,
        'status': tempStatus ?? 'Tersedia',
        'gambar': uploadedImage,
      });
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
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? "Edit Alat" : "Tambah Alat Baru",
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= IMAGE =================
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.black, width: 2),
                      image: imageFile != null
                          ? DecorationImage(
                              image: FileImage(imageFile!),
                              fit: BoxFit.cover,
                            )
                          : imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: imageFile == null && imageUrl == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_enhance_rounded,
                                  size: 40, color: Colors.grey[400]),
                              const SizedBox(height: 10),
                              const Text("Tambah Foto",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _label("Nama Alat"),
              _textfield(namaController, "Masukkan nama alat"),

              _label("Stok Barang"),
              _textfield(stokController, "Masukkan jumlah stok", isNumber: true),

              _label("Status Ketersediaan"),
              _dropdownStatus(),

              _label("Kategori Alat"),
              _dropdownKategori(),

              const SizedBox(height: 40),

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
                    isEdit ? "UPDATE DATA ALAT" : "SIMPAN DATA ALAT",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      );

  Widget _textfield(TextEditingController controller, String hint,
          {bool isNumber = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black)),
        child: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
          ),
        ),
      );

  Widget _dropdownStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: tempStatus,
          hint: const Text("Pilih status"),
          isExpanded: true,
          items: ["Tersedia", "Dipinjam", "Dalam Perbaikan"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => setState(() => tempStatus = val),
        ),
      ),
    );
  }

  Widget _dropdownKategori() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: kategoriId,
          hint: const Text("Pilih kategori"),
          isExpanded: true,
          items: kategoriList
              .map((e) => DropdownMenuItem<int>(
                    value: e['id_kategori'],
                    child: Text(e['nama_kategori']),
                  ))
              .toList(),
          onChanged: (val) => setState(() => kategoriId = val),
        ),
      ),
    );
  }
}
