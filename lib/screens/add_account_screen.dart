import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _initialBalance = 0.0;
  int _selectedColor = const Color(0xFF002B1D).value;
  int _selectedIcon = Icons.account_balance_wallet.codePoint;

  final List<Color> _colors = [
    const Color(0xFF002B1D),
    const Color(0xFF0D9488),
    const Color(0xFF1E40AF),
    const Color(0xFFB91C1C),
    const Color(0xFF7C3AED),
    const Color(0xFFF59E0B),
  ];

  final List<IconData> _icons = [
    Icons.account_balance_wallet,
    Icons.savings,
    Icons.credit_card,
    Icons.account_balance,
    Icons.payments,
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
    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Rekening',
          style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INFORMASI REKENING',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 20),
              _buildCard(cardColor, isDark, [
                _buildTextField('Nama Rekening', Icons.edit_outlined, (v) => _name = v!, isDark),
                const SizedBox(height: 20),
                _buildTextField('Saldo Awal', Icons.payments_outlined, (v) {
                  if (v != null && v.isNotEmpty) {
                    _initialBalance = double.tryParse(v) ?? 0.0;
                  }
                }, isDark, keyboardType: TextInputType.number, prefix: 'Rp '),
              ]),
              const SizedBox(height: 30),
              Text(
                'VISUALISASI',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 20),
              _buildCard(cardColor, isDark, [
                Text('Pilih Warna Tema', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 15),
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      final color = _colors[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color.value),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 22,
                          child: _selectedColor == color.value
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
                Text('Pilih Ikon Rekening', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: _icons.map((icon) {
                    final isSelected = _selectedIcon == icon.codePoint;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon.codePoint),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(_selectedColor) : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF002B1D)),
                          size: 24,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ]),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _saveAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002B1D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Text('Simpan Rekening', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Color cardColor, bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, Function(String?) onSaved, bool isDark, {TextInputType? keyboardType, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        TextFormField(
          style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF002B1D)),
            prefixText: prefix,
            prefixStyle: GoogleFonts.outfit(color: const Color(0xFF002B1D), fontWeight: FontWeight.bold),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
          validator: (value) {
            if (label == 'Nama Rekening' && (value == null || value.isEmpty)) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
          onSaved: onSaved,
        ),
      ],
    );
  }
}
