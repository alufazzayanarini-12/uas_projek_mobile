import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import 'category_history_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  void _showCategoryDialog([CategoryModel? category, int? parentId]) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    int selectedIcon = category?.iconCodePoint ?? 58167;
    int selectedColor = category?.colorValue ?? Colors.blue.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Kategori' : (parentId != null ? 'Tambah Sub-Kategori' : 'Tambah Kategori')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Kategori'),
                ),
                const SizedBox(height: 20),
                _buildQuickVisualPickers(selectedIcon, selectedColor, (icon, color) {
                  setDialogState(() {
                    selectedIcon = icon;
                    selectedColor = color;
                  });
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final provider = Provider.of<CategoryProvider>(context, listen: false);
                  if (isEditing) {
                    provider.updateCategory(category.copyWith(
                      name: nameController.text,
                      iconCodePoint: selectedIcon,
                      colorValue: selectedColor,
                    ));
                  } else {
                    provider.addCategory(CategoryModel(
                      name: nameController.text,
                      iconCodePoint: selectedIcon,
                      colorValue: selectedColor,
                      orderIndex: provider.categories.length,
                      parentId: parentId,
                    ));
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

  Widget _buildQuickVisualPickers(int selectedIcon, int selectedColor, Function(int, int) onChange) {
    return Column(
      children: [
        const Text('Pilih Ikon', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            58167, 58162, 58156, 58169, 58161, 58145, 58153, 58160, 58168, 58170
          ].map((code) => IconButton(
            icon: Icon(IconData(code, fontFamily: 'MaterialIcons')),
            color: selectedIcon == code ? Color(selectedColor) : Colors.grey,
            onPressed: () => onChange(code, selectedColor),
          )).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Pilih Warna', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            Colors.blue, Colors.red, Colors.green, Colors.orange, 
            Colors.purple, Colors.teal, Colors.pink, Colors.amber, Colors.indigo, Colors.brown
          ].map((color) => GestureDetector(
            onTap: () => onChange(selectedIcon, color.value),
            child: CircleAvatar(
              backgroundColor: color,
              radius: 15,
              child: selectedColor == color.value ? const Icon(Icons.check, color: Colors.white, size: 15) : null,
            ),
          )).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Kategori'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Diarsipkan'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCategoryDialog(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(false),
            _buildCategoryList(true),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(bool archived) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = archived ? provider.archivedCategories : provider.categories;

        if (list.isEmpty) {
          return Center(child: Text(archived ? 'Tidak ada kategori diarsipkan.' : 'Belum ada kategori aktif.'));
        }

        // Sort: pinned first, then by orderIndex
        final sortedList = [...list]..sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return a.orderIndex.compareTo(b.orderIndex);
        });

        return ReorderableListView.builder(
          itemCount: sortedList.length,
          onReorder: (oldIndex, newIndex) {
            if (!archived) {
              provider.reorderCategories(oldIndex, newIndex);
            }
          },
          itemBuilder: (context, index) {
            final category = sortedList[index];
            return _buildCategoryTile(category, provider);
          },
        );
      },
    );
  }

  Widget _buildCategoryTile(CategoryModel category, CategoryProvider provider) {
    final subCategories = provider.getSubCategories(category.id!);

    return ExpansionTile(
      key: ValueKey(category.id),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Color(category.colorValue).withOpacity(0.1),
            child: Icon(
              IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: Color(category.colorValue),
            ),
          ),
          if (category.isPinned)
            const Positioned(
              right: 0,
              top: 0,
              child: Icon(Icons.push_pin, size: 12, color: Colors.orange),
            ),
        ],
      ),
      title: Text(category.name, style: TextStyle(
        decoration: category.isArchived ? TextDecoration.lineThrough : null,
      )),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit': _showCategoryDialog(category); break;
                case 'sub': _showCategoryDialog(null, category.id); break;
                case 'pin': provider.togglePin(category); break;
                case 'archive': provider.toggleArchive(category); break;
                case 'delete': _confirmDelete(category, provider); break;
                case 'history': 
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CategoryHistoryScreen(category: category),
                  ));
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'sub', child: Text('Tambah Sub-Kategori')),
              PopupMenuItem(value: 'pin', child: Text(category.isPinned ? 'Lepas Pin' : 'Sematkan (Pin)')),
              PopupMenuItem(value: 'archive', child: Text(category.isArchived ? 'Aktifkan Kembali' : 'Arsipkan')),
              const PopupMenuItem(value: 'history', child: Text('Lihat Riwayat')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      children: subCategories.map((sub) => ListTile(
        contentPadding: const EdgeInsets.only(left: 40, right: 20),
        leading: Icon(
          IconData(sub.iconCodePoint, fontFamily: 'MaterialIcons'),
          color: Color(sub.colorValue),
          size: 20,
        ),
        title: Text(sub.name),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 16),
          onPressed: () => provider.deleteCategory(sub.id!),
        ),
      )).toList(),
    );
  }

  void _confirmDelete(CategoryModel category, CategoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              provider.deleteCategory(category.id!);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
