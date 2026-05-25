import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _dailyReminder = true;
  bool _monthlyReport = true;
  bool _budgetWarning = true;
  
  bool _isQuietModeActive = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 6, minute: 0);

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _quietStart,
    );
    if (picked != null && picked != _quietStart) {
      setState(() {
        _quietStart = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _quietEnd,
    );
    if (picked != null && picked != _quietEnd) {
      setState(() {
        _quietEnd = picked;
      });
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
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Pengaturan Notifikasi',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationToggle('Notifikasi Push', 'Terima pembaruan transaksi secara instan', _pushNotifications, (v) => setState(() => _pushNotifications = v), isDark, cardColor),
                const SizedBox(height: 20),
                _buildNotificationToggle('Pengingat Harian', 'Simpan uang setiap hari secara otomatis', _dailyReminder, (v) => setState(() => _dailyReminder = v), isDark, cardColor),
                const SizedBox(height: 20),
                _buildNotificationToggle('Laporan Bulanan', 'Ringkasan kesehatan finansial Anda', _monthlyReport, (v) => setState(() => _monthlyReport = v), isDark, cardColor),
                const SizedBox(height: 20),
                _buildNotificationToggle('Peringatan Anggaran', 'Beri tahu jika pengeluaran melebihi limit', _budgetWarning, (v) => setState(() => _budgetWarning = v), isDark, cardColor),
                const SizedBox(height: 40),
                _buildQuietModeCard(isDark, cardColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationToggle(String title, String subtitle, bool value, Function(bool) onChanged, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF002B1D),
          ),
        ],
      ),
    );
  }

  Widget _buildQuietModeCard(bool isDark, Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isQuietModeActive ? const Color(0xFF0D4D3B) : const Color(0xFF002B1D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isQuietModeActive ? const Color(0xFF10B981).withOpacity(0.3) : Colors.transparent),
        boxShadow: [
          if (_isQuietModeActive)
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _isQuietModeActive ? Icons.nights_stay : Icons.nightlight_round, 
                    color: Colors.white, 
                    size: 24
                  ),
                  const SizedBox(width: 15),
                  Text('Mode Hening Malam', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              if (_isQuietModeActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Aktif', 
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Mencegah notifikasi yang mengganggu selama periode istirahat malam.', 
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70)
          ),
          const SizedBox(height: 20),
          
          // Time Pickers Row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectStartTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jam Mulai', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatTime(_quietStart), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const Icon(Icons.access_time, color: Colors.white70, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectEndTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jam Selesai', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatTime(_quietEnd), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const Icon(Icons.access_time, color: Colors.white70, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 25),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isQuietModeActive = !_isQuietModeActive;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isQuietModeActive 
                        ? 'Mode Hening diaktifkan antara ${_formatTime(_quietStart)} - ${_formatTime(_quietEnd)}!'
                        : 'Mode Hening dinonaktifkan!',
                      style: GoogleFonts.outfit(),
                    ),
                    backgroundColor: const Color(0xFF002B1D),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isQuietModeActive ? Colors.transparent : Colors.white,
                foregroundColor: _isQuietModeActive ? Colors.white : const Color(0xFF002B1D),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: _isQuietModeActive ? const BorderSide(color: Colors.white, width: 1.5) : BorderSide.none,
                ),
              ),
              child: Text(
                _isQuietModeActive ? 'Nonaktifkan Mode Hening' : 'Aktifkan Sekarang', 
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
