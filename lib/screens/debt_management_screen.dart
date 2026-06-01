import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../models/debt_model.dart';
import '../models/debt_payment_model.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';

class DebtManagementScreen extends StatefulWidget {
  const DebtManagementScreen({super.key});

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen> {
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  DateTime? _selectedDueDate;
  DateTime? _selectedDebtReminderDateTime;
  String _debtType = 'hutang';
  final List<DebtModel> _debtNotes = [];
  final Map<int, List<DebtPaymentModel>> _paymentHistories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  @override
  void dispose() {
    _contactController.dispose();
    _amountController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _loadDebts() async {
    final debts = await DatabaseHelper.instance.readAllDebts();
    setState(() {
      _debtNotes.clear();
      _debtNotes.addAll(debts);
      _isLoading = false;
    });
  }

  Future<void> _loadPaymentsForDebt(int debtId) async {
    final payments = await DatabaseHelper.instance.readDebtPayments(debtId);
    setState(() {
      _paymentHistories[debtId] = payments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32), // Green header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(settings.translate('debt_management'), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMainHeader(settings),
          const SizedBox(height: 20),
          _buildSummaryCards(settings),
          const SizedBox(height: 30),
          _buildContactListHeader(settings),
          Expanded(child: _buildContactList(settings)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtBottomSheet(),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildMainHeader(SettingsProvider settings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Text(
            settings.translate('usage_status'),
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            'Rp 1.250.000',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(SettingsProvider settings) {
    final totalDebt = _debtNotes.where((debt) => debt.type == 'hutang').fold<double>(0, (sum, debt) => sum + debt.remainingAmount);
    final totalReceivable = _debtNotes.where((debt) => debt.type == 'piutang').fold<double>(0, (sum, debt) => sum + debt.remainingAmount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(settings.translate('my_debt'), fmt.format(totalDebt), Colors.red[50]!, Colors.red[700]!),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildSummaryCard(settings.translate('receivables'), fmt.format(totalReceivable), Colors.green[50]!, Colors.green[700]!),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.outfit(color: textColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(amount, style: GoogleFonts.outfit(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContactListHeader(SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          settings.translate('contact_list_title'),
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildContactList(SettingsProvider settings) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_debtNotes.isEmpty) {
      return Center(
        child: Text(
          settings.translate('empty_debt_message'),
          style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: _debtNotes.map((debt) {
        return _buildContactTile(
          debt,
          debt.type == 'hutang' ? Colors.red : Colors.green,
          settings,
        );
      }).toList(),
    );
  }

  Widget _buildContactTile(DebtModel debt, Color color, SettingsProvider settings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: () => _showDetailBottomSheet(debt),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Text(debt.contactName[0], style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold)),
        ),
        title: Text(debt.contactName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text(debt.type == 'hutang' ? settings.translate('hutang') : settings.translate('piutang'), style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: Text(fmt.format(debt.amount), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  void _showDetailBottomSheet(DebtModel debt) {
    _paymentController.clear();
    if (debt.id != null) {
      _loadPaymentsForDebt(debt.id!);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Provider.of<SettingsProvider>(context, listen: false)
                      .translate('detail_title')
                      .replaceAll('{name}', debt.contactName)
                      .replaceAll('{type}', debt.type == 'hutang' ? Provider.of<SettingsProvider>(context, listen: false).translate('hutang') : Provider.of<SettingsProvider>(context, listen: false).translate('piutang')),
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 15),
            Text(
              debt.type == 'hutang' ? 'Sisa Hutang' : 'Sisa Piutang',
              style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              fmt.format(debt.remainingAmount),
              style: GoogleFonts.outfit(color: debt.type == 'hutang' ? Colors.red : Colors.green, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _paymentController,
              decoration: InputDecoration(
                hintText: Provider.of<SettingsProvider>(context, listen: false).translate('nominal_bayar_cicil'),
                hintStyle: GoogleFonts.outfit(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final payment = double.tryParse(_paymentController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
                await _processPayment(debt, payment);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: Text(Provider.of<SettingsProvider>(context, listen: false).translate('bayar_sekarang'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 30),
            Text(
              Provider.of<SettingsProvider>(context, listen: false).translate('installment_history'),
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 15),
            Builder(builder: (context) {
              final historyKey = debt.id ?? -1;
              final payments = _paymentHistories[historyKey] ?? [];
              if (payments.isEmpty) {
                return Text('Belum ada riwayat cicilan', style: GoogleFonts.outfit(color: Colors.grey[600]));
              }
              return Column(
                children: payments.map((entry) {
                  return _buildHistoryItem(
                    DateFormat('dd MMM yyyy').format(entry.date),
                    fmt.format(entry.amount),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String date, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13)),
          Text(amount, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey[800])),
        ],
      ),
    );
  }

  void _showAddDebtBottomSheet() {
    // Fitur tambah kontak/hutang baru
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 25,
          top: 25,
          left: 25,
          right: 25,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catat Hutang Baru', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Nama Kontak', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Nominal Hutang', prefixText: 'Rp ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _debtType = 'hutang'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _debtType == 'hutang' ? Colors.white : Colors.black,
                      backgroundColor: _debtType == 'hutang' ? const Color(0xFF2E7D32) : Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Hutang'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _debtType = 'piutang'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _debtType == 'piutang' ? Colors.white : Colors.black,
                      backgroundColor: _debtType == 'piutang' ? const Color(0xFF2E7D32) : Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Piutang'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () => _selectDueDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDueDate != null
                            ? DateFormat('dd MMMM yyyy').format(_selectedDueDate!)
                            : 'Pilih tanggal jatuh tempo',
                        style: GoogleFonts.outfit(fontSize: 16, color: const Color(0xFF002B1D)),
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined, color: Color(0xFF002B1D)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () => _selectDebtReminderDateTime(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDebtReminderDateTime != null
                            ? DateFormat('dd MMM yyyy | HH:mm').format(_selectedDebtReminderDateTime!)
                            : 'Pilih tanggal & waktu pengingat',
                        style: GoogleFonts.outfit(fontSize: 16, color: const Color(0xFF002B1D)),
                      ),
                    ),
                    const Icon(Icons.alarm_outlined, color: Color(0xFF002B1D)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveDebt(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(DebtModel debt, double amount) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nominal cicilan tidak valid', style: GoogleFonts.outfit()), backgroundColor: Colors.red),
      );
      return;
    }

    final remaining = (debt.remainingAmount - amount).clamp(0.0, double.infinity).toDouble();
    final updatedDebt = debt.copyWith(
      remainingAmount: remaining,
      status: remaining == 0 ? 'paid' : debt.status,
    );

    final index = _debtNotes.indexWhere((item) => item.id == debt.id);
    if (index != -1) {
      setState(() {
        _debtNotes[index] = updatedDebt;
      });
    }

    if (debt.id != null) {
      await DatabaseHelper.instance.updateDebt(updatedDebt);
      final payment = DebtPaymentModel(debtId: debt.id!, amount: amount, date: DateTime.now());
      await DatabaseHelper.instance.createDebtPayment(payment);
      await _loadPaymentsForDebt(debt.id!);
    }

    final paymentHistory = _paymentHistories[debt.id] ?? [];
    setState(() {
      _paymentHistories[debt.id ?? -1] = [
        DebtPaymentModel(debtId: debt.id ?? -1, amount: amount, date: DateTime.now()),
        ...paymentHistory,
      ];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pembayaran berhasil dicatat', style: GoogleFonts.outfit()), backgroundColor: Colors.green),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E7D32),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  Future<void> _selectDebtReminderDateTime(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDebtReminderDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E7D32),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDebtReminderDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDebtReminderDateTime!)
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
          content: Text('Tanggal pengingat tidak boleh sebelum sekarang.', style: GoogleFonts.outfit()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _selectedDebtReminderDateTime = selectedDateTime;
    });
  }

  void _saveDebt(BuildContext context) async {
    if (_contactController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama kontak dan nominal harus diisi.', style: GoogleFonts.outfit()), backgroundColor: Colors.red),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nominal tidak valid.', style: GoogleFonts.outfit()), backgroundColor: Colors.red),
      );
      return;
    }

    final debt = DebtModel(
      contactName: _contactController.text,
      amount: amount,
      remainingAmount: amount,
      dueDate: _selectedDueDate,
      type: _debtType,
      reminderDateTime: _selectedDebtReminderDateTime,
    );

    await DatabaseHelper.instance.createDebt(debt);
    await _loadDebts();

    final notificationDate = _selectedDebtReminderDateTime ??
        (_selectedDueDate != null
            ? DateTime(_selectedDueDate!.year, _selectedDueDate!.month, _selectedDueDate!.day, 9, 0)
            : null);

    if (notificationDate != null && notificationDate.isAfter(DateTime.now())) {
      try {
        final ns = NotificationService();
        await ns.scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          title: 'Pengingat ${_debtType == 'hutang' ? 'Hutang' : 'Piutang'}',
          body: '${_contactController.text} ${_debtType == 'hutang' ? 'harus dibayar' : 'harus diterima'} pada ${DateFormat('dd MMM yyyy').format(notificationDate)}',
          scheduledDateTime: notificationDate,
        );
      } catch (e) {
        // ignore
      }
    }

    Navigator.pop(context);
    _contactController.clear();
    _amountController.clear();
    setState(() {
      _selectedDueDate = null;
      _selectedDebtReminderDateTime = null;
      _debtType = 'hutang';
    });
  }
}
