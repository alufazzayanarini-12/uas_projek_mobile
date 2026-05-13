import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
import 'package:intl/intl.dart';

class EditGoalScreen extends StatefulWidget {
  final Goal goal;

  const EditGoalScreen({
    super.key,
    required this.goal,
  });

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.name);
    _amountController = TextEditingController(text: widget.goal.targetAmount.toInt().toString());
    _selectedDate = widget.goal.deadline;
    _dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(_selectedDate!));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF002B1D),
              onPrimary: Colors.white,
              onSurface: Color(0xFF002B1D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveChanges() async {
    final name = _titleController.text.trim();
    final targetAmount = double.tryParse(_amountController.text) ?? 0.0;

    if (name.isEmpty || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon masukkan nama dan jumlah yang valid')),
      );
      return;
    }

    final updatedGoal = widget.goal.copyWith(
      name: name,
      targetAmount: targetAmount,
      deadline: _selectedDate,
    );

    await context.read<GoalProvider>().updateGoal(updatedGoal);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target berhasil diperbarui')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FE),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Ubah Target',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildCurrentTargetCard(isDark),
                const SizedBox(height: 25),
                _buildFormSection(isDark, textColor, cardColor),
                const SizedBox(height: 25),
                _buildAnalysisCard(isDark, textColor),
                const SizedBox(height: 30),
                TextButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Target?'),
                        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await context.read<GoalProvider>().deleteGoal(widget.goal.id!);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFB91C1C)),
                  label: Text(
                    'HAPUS TARGET INI',
                    style: GoogleFonts.outfit(color: const Color(0xFFB91C1C), fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomAction(isDark),
        );
      },
    );
  }

  Widget _buildCurrentTargetCard(bool isDark) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0D4D3B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TARGET SAAT INI',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          Text(
            widget.goal.name,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: currencyFormat.format(widget.goal.currentAmount), style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                TextSpan(text: ' / ${currencyFormat.format(widget.goal.targetAmount)}', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(bool isDark, Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField('NAMA TARGET', Icons.notes_rounded, _titleController, isDark),
          const SizedBox(height: 25),
          _buildInputField('JUMLAH TARGET (RP)', Icons.payments_outlined, _amountController, isDark, 
              helperText: 'Gunakan angka tanpa titik atau koma.', keyboardType: TextInputType.number),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: _buildInputField('TANGGAL PENCAPAIAN', Icons.calendar_today_outlined, _dateController, isDark, 
                  suffixIcon: Icons.calendar_month),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, bool isDark, {String? helperText, IconData? suffixIcon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey[700], letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.outfit(color: isDark ? Colors.white : const Color(0xFF002B1D), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9),
            prefixIcon: Icon(icon, color: const Color(0xFF002B1D)),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFF002B1D)) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Text(helperText, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600])),
        ],
      ],
    );
  }

  Widget _buildAnalysisCard(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0D4D3B), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calculate_outlined, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analisis Tabungan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 4),
                Text(
                  'Sistem akan menghitung ulang strategi menabung Anda berdasarkan target baru ini.',
                  style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      color: Colors.transparent,
      child: ElevatedButton.icon(
        onPressed: _saveChanges,
        icon: const Icon(Icons.check_circle_outline),
        label: Text('Simpan Perubahan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF002B1D),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 65),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }
}
