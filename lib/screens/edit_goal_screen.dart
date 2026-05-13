import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class EditGoalScreen extends StatefulWidget {
  final String currentTitle;
  final String currentAmount;

  const EditGoalScreen({
    super.key,
    required this.currentTitle,
    required this.currentAmount,
  });

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentTitle);
    _amountController = TextEditingController(text: '15.000.000');
    _dateController = TextEditingController(text: '12/24/2024');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
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
              'Ubah Target',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            actions: [
              CircleAvatar(
                radius: 18,
                backgroundImage: settings.getProfileImageProvider(),
              ),
              const SizedBox(width: 20),
            ],
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
                  onPressed: () {},
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0D4D3B),
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
          opacity: 0.1,
          fit: BoxFit.cover,
        ),
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
            widget.currentTitle,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'Rp 15jt ', style: GoogleFonts.outfit(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                TextSpan(text: '/ Rp 20jt', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 18)),
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
              helperText: 'Gunakan angka tanpa titik atau koma.'),
          const SizedBox(height: 25),
          _buildInputField('TANGGAL PENCAPAIAN', Icons.calendar_today_outlined, _dateController, isDark, 
              suffixIcon: Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, bool isDark, {String? helperText, IconData? suffixIcon}) {
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
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[700]),
                    children: [
                      const TextSpan(text: 'Dengan target ini, Anda perlu menyisihkan '),
                      TextSpan(text: 'Rp 1.250.000', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      const TextSpan(text: ' per bulan hingga Desember 2024.'),
                    ],
                  ),
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
        onPressed: () => Navigator.pop(context),
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
