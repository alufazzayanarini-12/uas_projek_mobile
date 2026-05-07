import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import 'debt_management_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kategori Tabungan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, catProvider, child) {
          final categories = catProvider.categories;

          if (categories.isEmpty) {
            return const Center(child: Text('Belum ada kategori. Klik + untuk menambah.'));
          }

          // ── MENGGUNAKAN REORDERABLE LIST VIEW UNTUK DRAG & DROP ──
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              catProvider.reorderCategories(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _buildCategoryCard(cat, index);
            },
          );
        },
      ),
      floatingActionButton: _buildCustomCategoryButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCategoryCard(CategoryModel cat, int index) {
    return Container(
      key: ValueKey(cat.id ?? index), // Diperlukan untuk ReorderableListView
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Color(cat.colorValue).withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(cat.colorValue), size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (cat.name.toLowerCase() == 'hutang') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DebtManagementScreen()));
                    } else {
                      _showEditCategoryDialog(cat);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A237E))),
                      if (cat.budgetLimit > 0) 
                        Text('Anggaran: ${fmt.format(cat.budgetLimit)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Anggaran')),
                  const PopupMenuItem(value: 'archive', child: Text('Arsip Kategori')),
                ],
                onSelected: (val) {
                  if (val == 'archive') Provider.of<CategoryProvider>(context, listen: false).toggleArchive(cat);
                  if (val == 'edit') _showEditCategoryDialog(cat);
                },
              ),
            ],
          ),
          // ── VISUAL ANGGARAN (BUDGET PROGRESS) ──
          if (cat.budgetLimit > 0) ...[
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.35, // Placeholder: Harusnya hitung dari transaksi asli
                backgroundColor: Colors.grey[100],
                color: Color(cat.colorValue),
                minHeight: 6,
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _showEditCategoryDialog(CategoryModel cat) {
    final budgetController = TextEditingController(text: cat.budgetLimit.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Anggaran ${cat.name}'),
        content: TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Batas Anggaran Bulanan', prefixText: 'Rp '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final newBudget = double.tryParse(budgetController.text) ?? 0;
              Provider.of<CategoryProvider>(context, listen: false).updateCategory(
                CategoryModel(
                  id: cat.id,
                  name: cat.name,
                  iconCodePoint: cat.iconCodePoint,
                  colorValue: cat.colorValue,
                  budgetLimit: newBudget,
                  isArchived: cat.isArchived,
                  orderIndex: cat.orderIndex,
                )
              );
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCategoryButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // Logika untuk menambah kategori baru dengan pilihan ikon & warna
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Tambah Kategori Kustom Sedang Disiapkan!')));
      },
      backgroundColor: Colors.black,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Kategori Kustom', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
