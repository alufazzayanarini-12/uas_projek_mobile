import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../category_history_screen.dart';

class EducationPlanningScreen extends StatefulWidget {
  final CategoryModel category;
  const EducationPlanningScreen({super.key, required this.category});

  @override
  State<EducationPlanningScreen> createState() => _EducationPlanningScreenState();
}

class _EducationPlanningScreenState extends State<EducationPlanningScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perencanaan Pendidikan'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              final provider = Provider.of<CategoryProvider>(context, listen: false);
              switch (value) {
                case 'pin': provider.togglePin(widget.category); break;
                case 'archive': 
                  provider.toggleArchive(widget.category);
                  Navigator.pop(context);
                  break;
                case 'delete': _confirmDelete(provider); break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pin', 
                child: ListTile(
                  leading: Icon(widget.category.isPinned ? Icons.push_pin_outlined : Icons.push_pin, size: 20),
                  title: Text(widget.category.isPinned ? 'Lepas Pin' : 'Sematkan'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'archive', 
                child: const ListTile(
                  leading: Icon(Icons.archive_outlined, size: 20),
                  title: Text('Arsipkan'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete', 
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  title: Text('Hapus', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalSummary(),
            const SizedBox(height: 32),
            const Text('Kategori Biaya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSubCategoryGrid(),
            const SizedBox(height: 32),
            const Text('Riwayat Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: CategoryHistoryScreen(category: widget.category),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tabungan Kuliah (Goal)', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          const Text('Rp 50.000.000', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const LinearProgressIndicator(
            value: 0.45,
            backgroundColor: Colors.white24,
            color: Colors.white,
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Terkumpul: Rp 22.500.000', style: TextStyle(color: Colors.white, fontSize: 12)),
              const Text('45%', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryGrid() {
    final subCats = [
      {'name': 'Uang Sekolah', 'icon': Icons.school, 'color': Colors.blue},
      {'name': 'Buku & Alat', 'icon': Icons.book, 'color': Colors.orange},
      {'name': 'Seragam', 'icon': Icons.checkroom, 'color': Colors.green},
      {'name': 'Kursus', 'icon': Icons.laptop, 'color': Colors.purple},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: subCats.length,
      itemBuilder: (context, index) {
        final item = subCats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (item['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (item['color'] as Color).withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'] as IconData, color: item['color'] as Color),
              const SizedBox(height: 8),
              Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(CategoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              provider.deleteCategory(widget.category.id!);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to management
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
