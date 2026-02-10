import 'package:flutter/material.dart';

class AlatPage extends StatefulWidget {
  const AlatPage({super.key});

  @override
  State<AlatPage> createState() => _AlatPageState();
}

class _AlatPageState extends State<AlatPage> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Laptop", "Mouse", "Kamera", "Proyektor"];

  String? tempStatus;
  String? tempCategory;

  final List<Map<String, String>> allItems = [
    {"name": "Laptop", "desc": "HP 14S-CF0130TU SILVER", "cat": "Laptop", "img": "https://p-id.ipricegroup.com/uploaded_3160a28303f909180f12c6680a69a47a.jpg"},
    {"name": "Mouse", "desc": "HP USB SCROLL", "cat": "Mouse", "img": "https://m.media-amazon.com/images/I/31697C6A0vL._AC_SY450_.jpg"},
    {"name": "Camera", "desc": "CANON EOS R KIT 24", "cat": "Kamera", "img": "https://m.media-amazon.com/images/I/718n4oDah2L._AC_SL1500_.jpg"},
    {"name": "Proyektor", "desc": "EPSON XGA 3 LCD", "cat": "Proyektor", "img": "https://m.media-amazon.com/images/I/51HkRWh80tL._AC_SL1000_.jpg"},
  ];

  // ===========================================================
  // 1. LOGIKA HALAMAN TAMBAH ALAT (FULL SCREEN)
  // ===========================================================
  void _goToTambahAlat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xffBBD7FF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Tambah Alat Baru", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_enhance_rounded, size: 40, color: Colors.grey[400]),
                              const SizedBox(height: 10),
                              const Text("Tambah Foto", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLabel("Nama Alat"),
                      _buildTextField("Masukkan nama alat"),
                      _buildLabel("Stok Barang"),
                      _buildTextField("Masukkan jumlah stok", isNumber: true),
                      _buildLabel("Status Ketersediaan"),
                      _buildDropdownImproved(
                        value: tempStatus,
                        hint: "Pilih status",
                        items: ["Tersedia", "Dipinjam", "Dalam Perbaikan"],
                        onChanged: (val) => setModalState(() => tempStatus = val),
                      ),
                      _buildLabel("Kategori Alat"),
                      _buildDropdownImproved(
                        value: tempCategory,
                        hint: "Pilih kategori",
                        items: ["Laptop", "Mouse", "Kamera", "Proyektor"],
                        onChanged: (val) => setModalState(() => tempCategory = val),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity, height: 55,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1B607A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("SIMPAN DATA ALAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // 2. LOGIKA KATEGORI (FULL SCREEN DAFTAR, TAMBAH, EDIT)
  // ===========================================================
  void _showKategoriManager() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xffBBD7FF),
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
            title: const Text("Daftar Kategori", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent, elevation: 0,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildSearchField("Cari kategori alat"),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.where((c) => c != "All").length,
                  itemBuilder: (context, index) {
                    final catName = categories.where((c) => c != "All").toList()[index];
                    return _buildCategoryItem(catName);
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _goToFormKategori(isEdit: false),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.black, width: 2)),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ),
    );
  }

  void _goToFormKategori({bool isEdit = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xffBBD7FF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
            title: Text(isEdit ? "Edit Kategori" : "Tambah Kategori Baru", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Nama Kategori"),
                _buildTextField("Masukkan nama kategori"),
                const SizedBox(height: 20),
                _buildLabel("Gambar Kategori"),
                Container(
                  width: double.infinity, height: 180,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black)),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Pilih Gambar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff1B607A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: Text(isEdit ? "SIMPAN PERUBAHAN" : "TAMBAHKAN KATEGORI", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Hapus", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("apakah anda yakin menghapus kategori alat ini", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: const StadiumBorder()),
                  child: const Text("Ya", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], shape: const StadiumBorder()),
                  child: const Text("Tidak", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // 3. WIDGET KOMPONEN PEMBANTU
  // ===========================================================
  
  Widget _buildCategoryItem(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        children: [
          // Icon Placeholder Gambar agar rapi
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: const Icon(Icons.image, color: Colors.grey, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
          // Tombol Edit dengan Teks
          _buildActionButton(
            label: "Edit", 
            icon: Icons.edit, 
            color: const Color(0xff1B607A), 
            onTap: () => _goToFormKategori(isEdit: true)
          ),
          const SizedBox(width: 8),
          // Tombol Hapus dengan Teks
          _buildActionButton(
            label: "Hapus", 
            icon: Icons.delete, 
            color: const Color(0xff8B0000), 
            onTap: _showDeleteDialog
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(String hint) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.black)),
    child: TextField(
      decoration: InputDecoration(
        hintText: hint, 
        border: InputBorder.none,
        suffixIcon: const Icon(Icons.search, color: Colors.black), // Icon Hitam di Kanan
      ),
    ),
  );

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
  );

  Widget _buildTextField(String hint, {bool isNumber = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black)),
    child: TextField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(hintText: hint, border: InputBorder.none),
    ),
  );

  Widget _buildDropdownImproved({required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, hint: Text(hint), isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ===========================================================
  // 4. MAIN BUILD (BERANDA ALAT)
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    final filteredItems = selectedCategory == "All" ? allItems : allItems.where((item) => item['cat'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF),
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Beranda Alat", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSearchField("Cari barang"),
          ),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedCategory == categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedCategory = categories[index]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xff1B607A) : Colors.white,
                        borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(categories[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildAlatCard(item['name']!, item['desc']!, item['img']!);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(onTap: _goToTambahAlat, child: _buildSmallFab(Icons.add, "Tambah")),
          const SizedBox(height: 10),
          GestureDetector(onTap: _showKategoriManager, child: _buildSmallFab(Icons.grid_view, "Kategori")),
        ],
      ),
    );
  }

  Widget _buildAlatCard(String title, String subtitle, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(3, 3))],
      ),
      child: Row(
        children: [
          Image.network(imageUrl, width: 80, height: 60, fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(fontSize: 10)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xff1B607A), borderRadius: BorderRadius.circular(10)),
                  child: const Text("Tersedia", style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallFab(IconData icon, String label) => Container(
    width: 65, height: 65,
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.black, width: 2),
      boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(3, 3))],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.black, size: 28),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}