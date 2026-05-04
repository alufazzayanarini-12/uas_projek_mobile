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
  bool _enableAutoDebit = false;
  double _autoDebitAmount = 0.0;
  int _autoDebitDate = 1;

  final List<Color> _colors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange, 
    Colors.purple, Colors.teal, Colors.pink, Colors.amber
  ];

  final List<IconData> _icons = [
    Icons.flag, Icons.home, Icons.directions_car, Icons.airplanemode_active,
    Icons.computer, Icons.smartphone, Icons.shopping_bag, Icons.favorite
  ];

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
        autoDebitAmount: _enableAutoDebit ? _autoDebitAmount : null,
        autoDebitDate: _enableAutoDebit ? _autoDebitDate : null,
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
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Target'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Picker Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: _imageFile != null 
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageFile == null 
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Pasang Foto Mimpi Kamu', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama Target (Maks. 50 Karakter)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama target tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nominal Target',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal target harus diisi';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Nominal tidak valid';
                  }
                  return null;
                },
                onSaved: (value) => _targetAmount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Saldo Awal (Opsional)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    _currentAmount = double.tryParse(value) ?? 0.0;
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Batas Waktu (Tenggat)'),
                subtitle: Text(DateFormat('dd MMMM yyyy').format(_deadline)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const Divider(),
              const Text('Pilih Warna & Ikon', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = _colors[index]),
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _colors[index],
                          shape: BoxShape.circle,
                          border: _selectedColor == _colors[index] ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = _icons[index]),
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _selectedIcon == _icons[index] ? Colors.grey[300] : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_icons[index], color: _selectedColor),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Aktifkan Simulasi Autodebit'),
                subtitle: const Text('Pindahkan saldo otomatis setiap bulan'),
                value: _enableAutoDebit,
                onChanged: (val) => setState(() => _enableAutoDebit = val),
              ),
              if (_enableAutoDebit) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nominal per bulan', prefixText: 'Rp '),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _autoDebitAmount = double.tryParse(value ?? '0') ?? 0,
                ),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Tanggal Penarikan'),
                  value: _autoDebitDate,
                  items: List.generate(28, (i) => DropdownMenuItem(value: i + 1, child: Text('Tanggal ${i + 1}'))),
                  onChanged: (val) => setState(() => _autoDebitDate = val!),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _saveGoal,
                  child: const Text('Simpan Target'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
