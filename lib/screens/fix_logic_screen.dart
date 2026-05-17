import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class FixLogicScreen extends StatefulWidget {
  final String category;
  final String currentAmount;
  final String currentLimit;

  const FixLogicScreen({
    super.key,
    required this.category,
    required this.currentAmount,
    required this.currentLimit,
  });

  @override
  State<FixLogicScreen> createState() => _FixLogicScreenState();
}

class _FixLogicScreenState extends State<FixLogicScreen> {
  late double _newLimit;
  bool _applyAutoLimit = true;
  late TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    // Parse current limit string like "Rp 500.000" to double
    String cleanLimit = widget.currentLimit.replaceAll('Rp ', '').replaceAll('.', '').replaceAll(',', '');
    _newLimit = double.tryParse(cleanLimit) ?? 500000;
    _limitController = TextEditingController(text: _newLimit.toInt().toString());
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
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
              'Perbaiki Logika',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                _buildStatusCard(isDark, textColor, cardColor),
                const SizedBox(height: 30),
                Text(
                  'KETIK MANUAL',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                ),
                const SizedBox(height: 15),
                _buildAdjustmentCard(isDark, textColor, cardColor),
                const SizedBox(height: 25),
                _buildRuleToggle(isDark, textColor, cardColor),
                const SizedBox(height: 40),
                _buildApplyButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(bool isDark, Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFB91C1C), size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.category, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    Text('Melebihi batas sebesar Rp 350.000', style: GoogleFonts.outfit(fontSize: 13, color: Colors.red[700])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Sekarang', widget.currentAmount, Colors.red[700]!),
              _buildStatItem('Uang Keluar', widget.currentLimit, textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildAdjustmentCard(bool isDark, Color textColor, Color cardColor) {
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
          Text('Sesuaikan Uang Keluar', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 20),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            onChanged: (val) {
              double? parsed = double.tryParse(val);
              if (parsed != null) {
                setState(() {
                  _newLimit = parsed;
                });
              }
            },
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
              labelText: 'Uang Keluar Baru',
              labelStyle: GoogleFonts.outfit(color: const Color(0xFF0D9488)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleToggle(bool isDark, Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF0D9488)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aktifkan Aturan Cerdas', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                Text('Blokir transaksi jika melebihi batas', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: _applyAutoLimit,
            onChanged: (v) => setState(() => _applyAutoLimit = v),
            activeColor: const Color(0xFF002B1D),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: () {
        double finalLimit = double.tryParse(_limitController.text) ?? _newLimit;
        if (widget.category == 'Makan dan Minum') {
          settings.setFoodLimit(finalLimit);
        } else if (widget.category == 'Transportasi & Pengiriman') {
          settings.setTransportLimit(finalLimit);
        }
        _showSuccessDialog(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF002B1D),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      child: Text('Terapkan Perbaikan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 50),
            ),
            const SizedBox(height: 25),
            Text('Logika Diperbaiki!', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              'Batas pengeluaran untuk ${widget.category} telah diperbarui dan aturan cerdas telah diaktifkan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to Auditor screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002B1D),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text('Selesai', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
