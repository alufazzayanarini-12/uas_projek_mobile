import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import 'debt_management_screen.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                onTap: () {
                  if (cat.name.toLowerCase() == 'hutang') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DebtManagementScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fitur untuk ${cat.name} akan segera hadir!')));
                  }
                },
                child: _buildCategoryCard(cat),
              );
            },
          );
        },
      ),
      floatingActionButton: _buildCustomCategoryButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCategoryCard(CategoryModel cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(cat.colorValue).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: Color(cat.colorValue),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              cat.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8E99AF)),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildCustomCategoryButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // Logika tambah kategori kustom bisa ditambahkan di sini
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Kategori Kustom',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
