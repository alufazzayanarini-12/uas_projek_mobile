import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';

class AddGoalScreen extends StatefulWidget {
  final Goal? goalToEdit;
  const AddGoalScreen({super.key, this.goalToEdit});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Tabungan';
  late DateTime _selectedDate;
  DateTime? _selectedReminderDateTime;

  SettingsProvider get settings => Provider.of<SettingsProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    if (widget.goalToEdit != null) {
      _nameController.text = widget.goalToEdit!.name;
      _amountController.text = widget.goalToEdit!.targetAmount.toInt().toString();
      _selectedCategory = widget.goalToEdit!.category;
      _selectedDate = widget.goalToEdit!.deadline;
      _selectedReminderDateTime = widget.goalToEdit!.reminderDateTime;
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 30));
      _selectedReminderDateTime = null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
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
      });
    }
  }

  Future<void> _selectReminderDateTime(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminderDateTime ?? now,
      firstDate: now,
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
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedReminderDateTime != null
          ? TimeOfDay.fromDateTime(_selectedReminderDateTime!)
          : TimeOfDay(hour: now.hour, minute: now.minute),
    );
    if (pickedTime == null) return;

    final selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (selectedDateTime.isBefore(now.add(const Duration(minutes: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settings.translate('tanggal_pengingat_tidak_valid'), style: GoogleFonts.outfit()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _selectedReminderDateTime = selectedDateTime;
    });
  }

  int _calculateMonths(DateTime targetDate) {
    final now = DateTime.now();
    int months = (targetDate.year - now.year) * 12 + targetDate.month - now.month;
    return months > 0 ? months : 0;
  }

  void _saveGoal() {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(settings.translate('nama_dan_nominal_harus_diisi'), style: GoogleFonts.outfit()), backgroundColor: Colors.red),
      );
      return;
    }

    final rawAmount = _amountController.text;
    final cleanedAmount = rawAmount.replaceAll(RegExp(r'[^0-9.]'), '');
    final double targetAmount = double.tryParse(cleanedAmount) ?? 0.0;
    if (targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(settings.translate('nominal_harus_diisi'), style: GoogleFonts.outfit()), backgroundColor: Colors.red),
      );
      return;
    }

    int colorValue = const Color(0xFF002B1D).value;
    int iconCode = Icons.flag.codePoint;
    if (_selectedCategory == 'Tabungan') { colorValue = 0xFF002B1D; iconCode = Icons.account_balance_wallet_outlined.codePoint; }
    else if (_selectedCategory == 'Investasi') { colorValue = 0xFF4CAF50; iconCode = Icons.trending_up.codePoint; }
    else if (_selectedCategory == 'Pembelian') { colorValue = 0xFF2196F3; iconCode = Icons.shopping_cart_outlined.codePoint; }
    else if (_selectedCategory == 'Darurat') { colorValue = 0xFFE91E63; iconCode = Icons.ac_unit.codePoint; }

    final goal = Goal(
      id: widget.goalToEdit?.id,
      name: _nameController.text,
      targetAmount: targetAmount,
      currentAmount: widget.goalToEdit?.currentAmount ?? 0.0,
      deadline: _selectedDate,
      color: colorValue,
      icon: iconCode,
      category: _selectedCategory,
      reminderDateTime: _selectedReminderDateTime,
    );

    if (widget.goalToEdit != null) {
      Provider.of<GoalProvider>(context, listen: false).updateGoal(goal);
    } else {
      Provider.of<GoalProvider>(context, listen: false).addGoal(goal);
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002B1D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.goalToEdit != null ? settings.translate('edit_target') : settings.translate('buat_target_baru'),
          style: GoogleFonts.outfit(color: const Color(0xFF002B1D), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundImage: settings.getProfileImageProvider(),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 25),
            _buildMainFormCard(cardColor, textColor),
            const SizedBox(height: 20),
            _buildEstimationCard(cardColor, textColor),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildMainFormCard(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.translate('nama_target'), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          TextField(
            controller: _nameController,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: settings.translate('contoh_nama_target'),
              hintStyle: GoogleFonts.outfit(color: Colors.grey.withOpacity(0.5)),
              border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
          const SizedBox(height: 25),
          Text(settings.translate('nominal_target'), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: 'Rp  ',
              prefixStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
              hintText: '0',
              border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
          const SizedBox(height: 25),
          Text(settings.translate('kategori_target'), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCategoryChip('Tabungan', Icons.account_balance_wallet_outlined, settings.translate('kategori_tabungan')),
              _buildCategoryChip('Pembelian', Icons.shopping_cart_outlined, settings.translate('kategori_pembelian')),
              _buildCategoryChip('Darurat', Icons.ac_unit, settings.translate('kategori_darurat')),
            ],
          ),
          const SizedBox(height: 25),
          Text(settings.translate('target_waktu'), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
                    ),
                  ),
                  const Icon(Icons.calendar_month_outlined, color: Color(0xFF002B1D)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(settings.translate('reminder_waktu'), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _selectReminderDateTime(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedReminderDateTime != null
                          ? DateFormat('dd MMM yyyy | HH:mm').format(_selectedReminderDateTime!)
                          : settings.translate('pilih_tanggal_pengingat'),
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
                    ),
                  ),
                  const Icon(Icons.alarm, color: Color(0xFF002B1D)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, IconData icon, String label) {
    bool isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF002B1D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF002B1D) : Colors.black.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionCard(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF002B1D), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.calculate_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(settings.translate('proyeksi_bulanan'), style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  Text('Rp 2.500.000', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: const LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Color(0xFFE8F0FE),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 15),
          Text(settings.translate('berdasarkan_target_12_bulan'), style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEstimationCard(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(settings.translate('estimasi_selesai'), style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              Text(DateFormat('MMMM yyyy').format(_selectedDate), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
              Text(settings.translate('dalam_bulan').replaceAll('{months}', _calculateMonths(_selectedDate).toString()), style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF10B981), fontWeight: FontWeight.w500)),
            ],
          ),
          const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 30),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ElevatedButton.icon(
        onPressed: _saveGoal,
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: Text(settings.translate('simpan_target'), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF002B1D),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
      ),
    );
  }
}
