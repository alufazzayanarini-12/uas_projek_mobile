import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _initialBalance = 0.0;
  int _selectedColor = Colors.blue.value;
  int _selectedIcon = Icons.account_balance_wallet.codePoint;

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  final List<IconData> _icons = [
    Icons.account_balance_wallet,
    Icons.savings,
    Icons.credit_card,
    Icons.account_balance,
    Icons.monetization_on,
    Icons.wallet_giftcard,
  ];

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final newAccount = Account(
        name: _name,
        balance: _initialBalance,
        colorValue: _selectedColor,
        iconCodePoint: _selectedIcon,
      );

      Provider.of<AccountProvider>(context, listen: false).addAccount(newAccount);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Rekening'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama Rekening',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama rekening tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
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
                    _initialBalance = double.tryParse(value) ?? 0.0;
                  }
                },
              ),
              const SizedBox(height: 24),
              const Text('Pilih Warna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color.value),
                    child: CircleAvatar(
                      backgroundColor: color,
                      child: _selectedColor == color.value
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Pilih Ikon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _icons.map((icon) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon.codePoint),
                    child: CircleAvatar(
                      backgroundColor: _selectedIcon == icon.codePoint ? Color(_selectedColor) : Colors.grey[200],
                      child: Icon(
                        icon,
                        color: _selectedIcon == icon.codePoint ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAccount,
                  child: const Text('Simpan Rekening'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
