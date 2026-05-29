import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import 'debt_management_screen.dart';
import 'personal_savings_screen.dart';
import 'education_fund_screen.dart';
import 'monthly_expenses_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final List<IconData> _availableIcons = [
    Icons.shopping_cart, Icons.restaurant, Icons.directions_car, Icons.movie,
    Icons.home, Icons.school, Icons.fitness_center, Icons.medical_services,
    Icons.flight, Icons.games, Icons.volunteer_activism, Icons.account_balance_wallet
  ];

  final List<Color> _availableColors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.cyan, Colors.teal,
    Colors.green, Colors.orange, Colors.brown, Colors.blueGrey
  ];

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
        title: Consumer<SettingsProvider>(
          builder: (context, settings, _) => Text(
            settings.translate('kategori_tabungan_title'),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, catProvider, child) {
          final categories = catProvider.categories;

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.category_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 15),
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(settings.translate('belum_ada_kategori'), style: const TextStyle(color: Colors.grey)),
                        ElevatedButton(
                          onPressed: () => catProvider.loadCategories(),
                          child: Text(settings.translate('refresh_data')),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) => catProvider.reorderCategories(oldIndex, newIndex),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _buildCategoryCard(cat, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Consumer<SettingsProvider>(
          builder: (context, settings, _) => Text(
            settings.translate('kategori_kustom'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCategoryCard(CategoryModel cat, int index) {
    return Container(
      key: ValueKey(cat.id ?? index),
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
                    final name = cat.name.toLowerCase();
                    if (name == 'hutang') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DebtManagementScreen()));
                    } else if (name == 'tabungan saya') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalSavingsScreen()));
                    } else if (name == 'pendidikan') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EducationFundScreen()));
                    } else if (name == 'uang bulanan') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MonthlyExpensesScreen()));
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A237E))),
                      if (cat.budgetLimit > 0) Text('${settings.translate('anggaran_prefix')}${fmt.format(cat.budgetLimit)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                itemBuilder: (context) => Consumer<SettingsProvider>(
                  builder: (context, settings, _) => [
                    PopupMenuItem(value: 'edit', child: Text(settings.translate('edit'))),
                    PopupMenuItem(value: 'archive', child: Text(settings.translate('arsip'))),
                    PopupMenuItem(value: 'delete', child: Text(settings.translate('hapus'), style: const TextStyle(color: Colors.red))),
                  ],
                ).build(context),
                onSelected: (val) {
                  if (val == 'archive') Provider.of<CategoryProvider>(context, listen: false).toggleArchive(cat);
                  if (val == 'edit') _showAddCategoryDialog(category: cat);
                  if (val == 'delete') _showDeleteConfirmation(cat);
                },
              ),
            ],
          ),
          if (cat.budgetLimit > 0) ...[
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: 0.35, backgroundColor: Colors.grey[100], color: Color(cat.colorValue), minHeight: 6),
            ),
          ]
        ],
      ),
    );
  }

  void _showDeleteConfirmation(CategoryModel cat) {
    showDialog(
      context: context,
      builder: (context) => Consumer<SettingsProvider>(
        builder: (context, settings, _) => AlertDialog(
          title: Text(settings.translate('hapus_kategori')),
          content: Text(settings.translate('yakin_hapus_kategori').replaceAll('{name}', cat.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(settings.translate('batal')),
            ),
            TextButton(
              onPressed: () {
                Provider.of<CategoryProvider>(context, listen: false).deleteCategory(cat.id!);
                Navigator.pop(context);
              },
              child: Text(settings.translate('hapus'), style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog({CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final budgetController = TextEditingController(text: category?.budgetLimit.toString() ?? '0');
    IconData selectedIcon = category != null ? IconData(category.iconCodePoint, fontFamily: 'MaterialIcons') : _availableIcons[0];
    Color selectedColor = category != null ? Color(category.colorValue) : _availableColors[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 25, left: 25, right: 25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) => Text(
                    category == null ? settings.translate('tambah_kategori_baru') : settings.translate('edit_kategori'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(controller: nameController, decoration: InputDecoration(labelText: SettingsProvider().translate('nama_kategori'), border: const OutlineInputBorder())),
                const SizedBox(height: 20),
                TextField(controller: budgetController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: SettingsProvider().translate('batas_anggaran_bulanan'), prefixText: 'Rp ', border: const OutlineInputBorder())),
                const SizedBox(height: 25),
                Text(SettingsProvider().translate('pilih_ikon'), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = _availableIcons[i]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: selectedIcon == _availableIcons[i] ? Colors.black : Colors.grey[100], shape: BoxShape.circle),
                        child: Icon(_availableIcons[i], color: selectedIcon == _availableIcons[i] ? Colors.white : Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(SettingsProvider().translate('pilih_warna'), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableColors.length,
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => setModalState(() => selectedColor = _availableColors[i]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        width: 40,
                        decoration: BoxDecoration(color: _availableColors[i], shape: BoxShape.circle, border: Border.all(color: selectedColor == _availableColors[i] ? Colors.black : Colors.transparent, width: 3)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        final newCat = CategoryModel(
                          id: category?.id,
                          name: nameController.text,
                          iconCodePoint: selectedIcon.codePoint,
                          colorValue: selectedColor.value,
                          budgetLimit: double.tryParse(budgetController.text) ?? 0.0,
                          isArchived: category?.isArchived ?? false,
                        );
                        if (category == null) {
                          Provider.of<CategoryProvider>(context, listen: false).addCategory(newCat);
                        } else {
                          Provider.of<CategoryProvider>(context, listen: false).updateCategory(newCat);
                        }
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: Text(SettingsProvider().translate('simpan_kategori'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
