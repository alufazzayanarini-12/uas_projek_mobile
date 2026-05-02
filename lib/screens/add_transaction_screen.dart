import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../providers/account_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Account account;
  const AddTransactionScreen({super.key, required this.account});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'deposit'; // 'deposit' or 'withdrawal'
  double _amount = 0.0;
  String _description = '';

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validasi saldo jika penarikan
      if (_type == 'withdrawal' && _amount > widget.account.balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saldo tidak mencukupi untuk penarikan ini.')),
        );
        return;
      }

      final transaction = TransactionModel(
        accountId: widget.account.id!,
        type: _type,
        amount: _amount,
        description: _description,
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Setor (Masuk)'),
                      value: 'deposit',
                      groupValue: _type,
                      onChanged: (value) => setState(() => _type = value!),
                      activeColor: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Tarik (Keluar)'),
                      value: 'withdrawal',
                      groupValue: _type,
                      onChanged: (value) => setState(() => _type = value!),
                      activeColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nominal',
                  border: const OutlineInputBorder(),
                  prefixText: 'Rp ',
                  prefixIcon: Icon(
                    _type == 'deposit' ? Icons.arrow_downward : Icons.arrow_upward,
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == 'deposit' ? Colors.green : Colors.red,
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
