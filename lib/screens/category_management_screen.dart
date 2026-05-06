import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import 'category_detail_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  // ── PEMILIH IKON ──
  final List<IconData> _availableIcons = [
    Icons.shopping_bag, Icons.directions_car, Icons.flight, Icons.school,
    Icons.shield, Icons.home, Icons.health_and_safety, Icons.category,
    Icons.smartphone, Icons.computer, Icons.favorite, Icons.savings,
    Icons.fastfood, Icons.celebration, Icons.fitness_center, Icons.work
  ];

  // ── PEMILIH WARNA ──
  final List<Color> _availableColors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple,
    Colors.teal, Colors.pink, Colors.amber, Colors.cyan, Colors.indigo,
    Colors.brown, Colors.blueGrey, Colors.deepOrange, Colors.deepPurple
  ];

  void _showCategoryDialog({CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    int selectedIconCode = category?.iconCodePoint ?? Icons.category.codePoint;
    int selectedColorValue = category?.colorValue ?? Colors.blue.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(category == null ? 'Kategori Baru' : 'Ubah Kategori', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    prefixIcon: Icon(IconData(selectedIconCode, fontFamily: 'MaterialIcons'), color: Color(selectedColorValue)),
                  ),
                ),
                const SizedBox(height: 25),
                const Align(alignment: Alignment.centerLeft, child: Text('Pilih Ikon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  width: double.maxFinite,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = selectedIconCode == icon.codePoint;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedIconCode = icon.codePoint),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Color(selectedColorValue).withOpacity(0.1) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: Color(selectedColorValue), width: 2) : null,
                          ),
                          child: Icon(icon, color: isSelected ? Color(selectedColorValue) : Colors.grey[600]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
                const Align(alignment: Alignment.centerLeft, child: Text('Pilih Warna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableColors.length,
                    itemBuilder: (context, index) {
                      final color = _availableColors[index];
                      final isSelected = selectedColorValue == color.value;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColorValue = color.value),
                        child: Container(
                          width: 40,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newCat = CategoryModel(
                    id: category?.id,
                    name: nameController.text,
                    iconCodePoint: selectedIconCode,
                    colorValue: selectedColorValue,
                  );
                  if (category == null) {
                    Provider.of<CategoryProvider>(context, listen: false).addCategory(newCat);
                  } else {
                    Provider.of<CategoryProvider>(context, listen: false).updateCategory(newCat);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Urutkan & Kelola', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          final categories = provider.categories;

          if (categories.isEmpty) {
            return const Center(child: Text('Belum ada kategori.', style: TextStyle(color: Colors.grey)));
          }

          // ── REORDERABLE LIST VIEW (DRAG & DROP) ──
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: categories.length,
            onReorder: (oldIdx, newIdx) => provider.reorderCategories(oldIdx, newIdx),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isExpanded = _expandedIndex == index;
              final catColor = Color(cat.colorValue);

              return GestureDetector(
                key: ValueKey(cat.id), // Penting untuk Reorderable
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isExpanded ? catColor.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isExpanded ? catColor.withOpacity(0.3) : Colors.grey.shade100,
                      width: isExpanded ? 2 : 1,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      // Handle Drag
                      const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      // Icon Kategori
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: catColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'), color: catColor, size: 22),
                      ),
                      const SizedBox(width: 15),
                      // Nama
                      Expanded(
                        child: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      if (isExpanded)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_new, color: Colors.green, size: 20),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailScreen(category: cat))),
                            ),
                            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showCategoryDialog(category: cat)),
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => provider.deleteCategory(cat.id!)),
                          ],
                        )
                      else
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: Colors.black,
        label: const Text('Kategori Kustom', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
