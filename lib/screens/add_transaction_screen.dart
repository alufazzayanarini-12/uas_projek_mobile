import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Account account;
  const AddTransactionScreen({super.key, required this.account});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'deposit'; // 'deposit', 'withdrawal', or 'transfer'
  double _amount = 0.0;
  String _description = '';
  int? _selectedCategoryId;
  int? _targetAccountId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validasi saldo jika penarikan atau transfer
      if ((_type == 'withdrawal' || _type == 'transfer') && _amount > widget.account.balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saldo tidak mencukupi untuk transaksi ini.')),
        );
        return;
      }

      if (_type == 'transfer' && _targetAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih akun tujuan transfer.')),
        );
        return;
      }

      final transaction = TransactionModel(
        accountId: widget.account.id!,
        type: _type,
        amount: _amount,
        description: _description,
        categoryId: _selectedCategoryId,
        targetAccountId: _targetAccountId,
      );

      Provider.of<AccountProvider>(context, listen: false).addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Color(widget.account.colorValue).withOpacity(0.1),
                elevation: 0,
                child: ListTile(
                  leading: Icon(IconData(widget.account.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(widget.account.colorValue)),
                  title: Text(widget.account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Saldo: Rp ${widget.account.balance.toStringAsFixed(0)}'),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: RadioListTile<String>(
                        title: const Text('Setor', style: TextStyle(fontSize: 12)),
                        value: 'deposit',
                        groupValue: _type,
                        onChanged: (value) => setState(() => _type = value!),
                        activeColor: Colors.green,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: RadioListTile<String>(
                        title: const Text('Tarik', style: TextStyle(fontSize: 12)),
                        value: 'withdrawal',
                        groupValue: _type,
                        onChanged: (value) => setState(() => _type = value!),
                        activeColor: Colors.red,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: RadioListTile<String>(
                        title: const Text('Transfer', style: TextStyle(fontSize: 12)),
                        value: 'transfer',
                        groupValue: _type,
                        onChanged: (value) => setState(() => _type = value!),
                        activeColor: Colors.blue,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              if (_type == 'transfer') ...[
                const SizedBox(height: 16),
                Consumer<AccountProvider>(
                  builder: (context, provider, child) {
                    final otherAccounts = provider.accounts.where((a) => a.id != widget.account.id).toList();
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Akun Tujuan (Penerima)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      ),
                      value: _targetAccountId,
                      items: otherAccounts.map((acc) {
                        return DropdownMenuItem<int>(
                          value: acc.id,
                          child: Text(acc.name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _targetAccountId = value),
                      validator: (value) => _type == 'transfer' && value == null ? 'Pilih akun tujuan' : null,
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nominal',
                  border: const OutlineInputBorder(),
                  prefixText: 'Rp ',
                  prefixIcon: Icon(
                    _type == 'deposit' ? Icons.trending_up : Icons.trending_down,
                    color: _type == 'deposit' ? Colors.green : Colors.red,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal harus diisi';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Nominal tidak valid';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Keterangan / Catatan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Keterangan harus diisi';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    value: _selectedCategoryId,
                    items: provider.categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(cat.colorValue), size: 20),
                            const SizedBox(width: 10),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategoryId = value),
                    validator: (value) => value == null ? 'Pilih kategori' : null,
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == 'deposit' 
                      ? Colors.green 
                      : (_type == 'withdrawal' ? Colors.red : Colors.blue),
                  ),
                  child: const Text('Simpan Transaksi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
