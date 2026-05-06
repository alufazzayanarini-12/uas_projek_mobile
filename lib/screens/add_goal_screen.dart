import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/goal.dart';
import '../providers/goal_provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _targetAmount = 0.0;
  double _currentAmount = 0.0;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.flag;
  File? _imageFile;
  String _selectedCategory = 'Lainnya';

  // Controller untuk input nominal
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _applyCategory(_selectedCategory);
    _amountController.addListener(() {
      setState(() {
        _targetAmount = double.tryParse(_amountController.text) ?? 0.0;
      });
    });
  }

  void _applyCategory(String categoryName) {
    final preset = Goal.getCategoryPreset(categoryName);
    if (preset != null) {
      setState(() {
        _selectedCategory = categoryName;
        _selectedColor = Color(preset['color'] as int);
        _selectedIcon = IconData(preset['icon'] as int, fontFamily: 'MaterialIcons');
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final goal = Goal(
        name: _name,
        targetAmount: _targetAmount,
        currentAmount: _currentAmount,
        deadline: _deadline,
        color: _selectedColor.value,
        icon: _selectedIcon.codePoint,
        imagePath: _imageFile?.path,
        category: _selectedCategory,
      );

      Provider.of<GoalProvider>(context, listen: false).addGoal(goal);
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Target Baru', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. KATEGORI (SCROLL & CHIPS) ──
                    const Text('Pilih Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: Goal.presetCategories.map((cat) {
                          final isSelected = _selectedCategory == cat['name'];
                          final catColor = Color(cat['color'] as int);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat['name'] as String),
                              selected: isSelected,
                              onSelected: (val) => _applyCategory(cat['name'] as String),
                              avatar: isSelected 
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Icon(IconData(cat['icon'] as int, fontFamily: 'MaterialIcons'), size: 16, color: catColor),
                              selectedColor: catColor,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              backgroundColor: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ── 2. PASANG FOTO (DASHED BOX) ──
                    const Text('Pasang Foto Mimpi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: _imageFile == null 
                              ? Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid) // Note: Flutter dash border needs custom painter, using solid for now
                              : null,
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  Text('Klik untuk pilih foto dari galeri', 
                                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                  Text('Area ini bisa diklik seluruhnya', 
                                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ── 3. FORM INPUT ──
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nama Target',
                        hintText: 'Contoh: Laptop Baru',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        prefixIcon: Icon(Icons.flag, color: _selectedColor),
                      ),
                      onChanged: (val) => setState(() => _name = val),
                      validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                      onSaved: (value) => _name = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Nominal Target',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        prefixIcon: Icon(Icons.attach_money, color: _selectedColor),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Nominal harus diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade300)),
                      leading: Icon(Icons.calendar_today, color: _selectedColor),
                      title: const Text('Tenggat Waktu'),
                      subtitle: Text(DateFormat('dd MMMM yyyy').format(_deadline), style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.edit, size: 20),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // ── 4. PREVIEW INSTAN (BOTTOM STICKY) ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('PREVIEW TARGET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _selectedColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      // Circular Icon/Image Preview
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          image: _imageFile != null 
                              ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _imageFile == null 
                            ? Icon(_selectedIcon, color: _selectedColor)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_name.isEmpty ? 'Nama Target' : _name, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(_selectedCategory, 
                              style: TextStyle(color: _selectedColor, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Rp ${NumberFormat('#,###').format(_targetAmount)}', 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          Text(DateFormat('dd MMM yyyy').format(_deadline), 
                            style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text('SIMPAN TARGET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
