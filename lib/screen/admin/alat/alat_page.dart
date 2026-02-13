import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'alat_add.dart';
import 'kategori_page.dart';

class AlatPage extends StatefulWidget {
  const AlatPage({super.key});

  @override
  State<AlatPage> createState() => _AlatPageState();
}

class _AlatPageState extends State<AlatPage> {
  final supabase = Supabase.instance.client;

  String selectedCategory = "All";
  final List<String> categories = ["All", "Laptop", "Mouse", "Kamera", "Proyektor"];

  List<Map<String, dynamic>> allItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlat();
  }

  // ================================
  // FETCH DATA SUPABASE
  // ================================
  Future<void> fetchAlat() async {
    final data = await supabase
        .from('alat')
        .select('''
          id_alat,
          nama_alat,
          jumlah,
          status,
          gambar,
          kategori(nama_kategori)
        ''');

    setState(() {
      allItems = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
  }

  void _goToTambahAlat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AlatAddPage(),
      ),
    );

    fetchAlat(); // refresh setelah tambah
  }

  void _showKategoriManager() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KategoriPage(categories: categories),
      ),
    );
  }

  Widget _buildSearchField(String hint) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.black)),
        child: TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            suffixIcon: const Icon(Icons.search, color: Colors.black),
          ),
        ),
      );

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
      );

  Widget _buildTextField(String hint, {bool isNumber = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black)),
        child: TextField(
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(hintText: hint, border: InputBorder.none),
        ),
      );

  Widget _buildDropdownImproved(
      {required String? value,
      required String hint,
      required List<String> items,
      required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = selectedCategory == "All"
        ? allItems
        : allItems.where((item) {
            final cat = item['kategori']?['nama_kategori'] ?? "";
            return cat == selectedCategory;
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffBBD7FF),
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        title: const Text("Beranda Alat",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(categories[index],
                            style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

                      return _buildAlatCard(
                        item['nama_alat'] ?? '',
                        "Jumlah: ${item['jumlah'] ?? 0}",
                        item['gambar'] ??
                            "https://via.placeholder.com/150",
                      );
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(3, 3))],
      ),
      child: Row(
        children: [
          Image.network(
            imageUrl,
            width: 80,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(fontSize: 10)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xff1B607A),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text("Tersedia",
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallFab(IconData icon, String label) => Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(3, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 28),
            Text(label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
