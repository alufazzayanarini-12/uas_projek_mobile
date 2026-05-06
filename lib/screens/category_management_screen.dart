import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';

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

  // ── DIALOG EDIT / TAMBAH KATEGORI ──
  void _showCategoryDialog({CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    int selectedIcon = category?.iconCodePoint ?? 0xe1b1; // Icons.category
    int selectedColor = category?.colorValue ?? 0xFF2196F3; // Default Blue

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(category == null ? 'Kategori Baru' : 'Ubah Kategori', 
            style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(IconData(selectedIcon, fontFamily: 'MaterialIcons'), color: Color(selectedColor)),
                ),
              ),
              const SizedBox(height: 20),
              const Align(alignment: Alignment.centerLeft, child: Text('Pilih Warna Tema:', style: TextStyle(fontSize: 12, color: Colors.grey))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _colorOption(setDialogState, Colors.blue.value, selectedColor, (val) => selectedColor = val),
                  _colorOption(setDialogState, Colors.red.value, selectedColor, (val) => selectedColor = val),
                  _colorOption(setDialogState, Colors.green.value, selectedColor, (val) => selectedColor = val),
                  _colorOption(setDialogState, Colors.orange.value, selectedColor, (val) => selectedColor = val),
                  _colorOption(setDialogState, Colors.purple.value, selectedColor, (val) => selectedColor = val),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newCat = CategoryModel(
                    id: category?.id,
                    name: nameController.text,
                    iconCodePoint: selectedIcon,
                    colorValue: selectedColor,
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

  Widget _colorOption(Function setDialogState, int color, int current, Function(int) onSelect) {
    return GestureDetector(
      onTap: () => setDialogState(() => onSelect(color)),
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: Color(color),
          shape: BoxShape.circle,
          border: current == color ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manajemen Kategori', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
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
          if (provider.categories.isEmpty) {
            return const Center(child: Text('Belum ada kategori.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final cat = provider.categories[index];
              final isExpanded = _expandedIndex == index;
              final catColor = Color(cat.colorValue);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
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
                    color: isExpanded ? Colors.blue.withOpacity(0.02) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    // ── BORDER BIRU MUDA SAAT AKTIF ──
                    border: Border.all(
                      color: isExpanded ? Colors.blue.withOpacity(0.3) : Colors.grey.shade100,
                      width: isExpanded ? 2 : 1,
                    ),
                    boxShadow: isExpanded 
                        ? [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10)]
                        : [],
                  ),
                  child: Row(
                    children: [
                      // Ikon Kategori
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'), color: catColor, size: 24),
                      ),
                      const SizedBox(width: 15),
                      // Nama Kategori
                      Expanded(
                        child: Text(cat.name, style: TextStyle(fontWeight: isExpanded ? FontWeight.w800 : FontWeight.w600, fontSize: 16)),
                      ),
                      // ── KONTROL EDIT / HAPUS SAAT AKTIF ──
                      if (isExpanded)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
                              onPressed: () => _showCategoryDialog(category: cat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                              onPressed: () {
                                provider.deleteCategory(cat.id!);
                                setState(() => _expandedIndex = null);
                              },
                            ),
                          ],
                        )
                      else
                        // ── CHEVRON SAAT TIDAK AKTIF ──
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // ── FLOATING ACTION BUTTON BIRU ──
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
