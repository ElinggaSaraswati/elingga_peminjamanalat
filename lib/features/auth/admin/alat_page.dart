import 'package:flutter/material.dart';

class AlatPage extends StatefulWidget {
  const AlatPage({super.key});

  @override
  State<AlatPage> createState() => _AlatPageState();
}

class _AlatPageState extends State<AlatPage> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Laptop", "Mouse", "Kamera", "Proyektor"];

  final List<Map<String, String>> allItems = [
    {"name": "Laptop", "desc": "HP 14S-CF0130TU SILVER", "cat": "Laptop", "img": "https://p-id.ipricegroup.com/uploaded_3160a28303f909180f12c6680a69a47a.jpg"},
    {"name": "Mouse", "desc": "HP USB SCROLL", "cat": "Mouse", "img": "https://m.media-amazon.com/images/I/31697C6A0vL._AC_SY450_.jpg"},
    {"name": "Camera", "desc": "CANON EOS R KIT 24", "cat": "Kamera", "img": "https://m.media-amazon.com/images/I/718n4oDah2L._AC_SL1500_.jpg"},
    {"name": "Proyektor", "desc": "EPSON XGA 3 LCD", "cat": "Proyektor", "img": "https://m.media-amazon.com/images/I/51HkRWh80tL._AC_SL1000_.jpg"},
  ];

  // --- 1. POPUP TAMBAH ALAT ---
  void _showTambahDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xffBBD7FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 150, height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 50),
                      Positioned(bottom: 5, right: 5, child: Icon(Icons.add_circle, color: Colors.black)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel("Nama"),
              _buildTextField("Masukkan nama alat"),
              _buildLabel("Stok"),
              _buildTextField("Masukkan stok alat"),
              _buildLabel("Status"),
              _buildDropdown(["Pilih status", "Ada", "Dipinjam"]),
              _buildLabel("Kategori"),
              _buildDropdown(["Pilih kategori alat", "Laptop", "Mouse", "Kamera", "Proyektor"]),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. POPUP EDIT ALAT ---
  void _showEditDialog(String name, String img) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xffBBD7FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(img, height: 80, fit: BoxFit.contain),
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel("Status"),
              _buildTextField("Terpinjam"),
              _buildLabel("Stok"),
              _buildTextField("5"),
              _buildLabel("Kategori"),
              _buildDropdown(["Laptop", "Mouse", "Kamera", "Proyektor"]),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Colors.black)), child: const Text("Batal", style: TextStyle(color: Colors.black))),
                  ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff1B607A)), child: const Text("Simpan", style: TextStyle(color: Colors.white))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- 3. POPUP HAPUS ALAT ---
  void _showHapusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Hapus", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("apakah anda yakin menghapus alat ini", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: const StadiumBorder()), child: const Text("Ya", style: TextStyle(color: Colors.white))),
                ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], shape: const StadiumBorder()), child: const Text("Tidak", style: TextStyle(color: Colors.white))),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(top: 10, bottom: 5), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));
  Widget _buildTextField(String hint) => Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black)), child: TextField(decoration: InputDecoration(hintText: hint, border: InputBorder.none)));
  Widget _buildDropdown(List<String> items) => Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black)), child: DropdownButton<String>(isExpanded: true, underline: const SizedBox(), value: items[0], items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) {}));

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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.black, width: 1.5)),
              child: const TextField(decoration: InputDecoration(hintText: "Cari barang", border: InputBorder.none, suffixIcon: Icon(Icons.search, color: Colors.black))),
            ),
          ),
          SizedBox(
            height: 40,
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
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(color: isSelected ? const Color(0xff1B607A) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black)),
                      child: Center(child: Text(categories[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
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
          GestureDetector(onTap: _showTambahDialog, child: _buildSmallFab(Icons.add, "Tambah")),
          const SizedBox(height: 10),
          _buildSmallFab(Icons.grid_view, "Kategori"),
        ],
      ),
    );
  }

  Widget _buildAlatCard(String title, String subtitle, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 1.5), boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(3, 3))]),
      child: Row(
        children: [
          Container(width: 80, height: 60, decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.contain))),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                const SizedBox(height: 5),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xff1B607A), borderRadius: BorderRadius.circular(10)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle_outline, color: Colors.white, size: 12), SizedBox(width: 4), Text("Tersedia", style: TextStyle(color: Colors.white, fontSize: 10))])),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(onTap: () => _showEditDialog(title, imageUrl), child: _buildActionButton(Icons.edit, "Edit", const Color(0xff1B607A))),
              const SizedBox(height: 5),
              GestureDetector(onTap: _showHapusDialog, child: _buildActionButton(Icons.delete, "Hapus", const Color(0xff8B0000))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) => Container(width: 70, padding: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 12, color: Colors.white), const SizedBox(width: 4), Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]));

  Widget _buildSmallFab(IconData icon, String label) => Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black, width: 1.5), boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2))]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.black, size: 25), Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))]));
}