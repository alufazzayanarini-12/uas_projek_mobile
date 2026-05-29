import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

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
              settings.translate('kata_sandi_keamanan'),
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(25),
            children: [
              _buildSecurityTile(
                Icons.lock_reset_rounded,
                settings.translate('ubah_pin_transaksi'),
                settings.translate('terakhir_diubah'),
                isDark,
                textColor,
                cardColor,
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                Icons.fingerprint_rounded,
                settings.translate('biometrik'),
                settings.translate('gunakan_sidik_jari'),
                settings.isBiometricEnabled,
                (v) => _showBiometricSimulation(context, settings, v, isDark),
                isDark,
                textColor,
                cardColor,
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                Icons.security_update_good_rounded,
                settings.translate('kunci_aplikasi'),
                settings.translate('kunci_aplikasi_subtitle'),
                settings.isAppLockEnabled,
                (v) => settings.toggleAppLock(v),
                isDark,
                textColor,
                cardColor,
              ),
              const SizedBox(height: 40),
              Text(
                settings.translate('perangkat_terhubung'),
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
              ),
              const SizedBox(height: 15),
              _buildDeviceTile('Xiaomi 12 Pro', settings.translate('aktif_sekarang'), true, isDark, cardColor),
              const SizedBox(height: 10),
              _buildDeviceTile('MacBook Air M2', settings.translate('terakhir_aktif_2_jam_lalu'), false, isDark, cardColor),
            ],
          ),
        );
      },
    );
  }

  void _showBiometricSimulation(BuildContext context, SettingsProvider settings, bool newValue, bool isDark) {
    if (newValue == false) {
      settings.toggleBiometric(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            settings.translate('biometrik_dinonaktifkan'),
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: Colors.red[800],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _BiometricScannerSheet(
          settings: settings,
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildSecurityTile(IconData icon, String title, String subtitle, bool isDark, Color textColor, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF002B1D)),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged, bool isDark, Color textColor, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF002B1D)),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF002B1D),
        ),
      ),
    );
  }

  Widget _buildDeviceTile(String name, String status, bool isActive, bool isDark, Color cardColor) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          ),
          child: Row(
            children: [
              Icon(Icons.devices_rounded, color: isActive ? Colors.green : Colors.grey),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    Text(status, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              if (!isActive) Text(settings.translate('hapus'), style: GoogleFonts.outfit(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}

class _BiometricScannerSheet extends StatefulWidget {
  final SettingsProvider settings;
  final bool isDark;

  const _BiometricScannerSheet({
    required this.settings,
    required this.isDark,
  });

  @override
  State<_BiometricScannerSheet> createState() => _BiometricScannerSheetState();
}

class _BiometricScannerSheetState extends State<_BiometricScannerSheet> {
  bool _isScanning = false;
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF002B1D);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            widget.settings.translate('verifikasi_biometrik'),
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.settings.translate(_isSuccess 
              ? 'otentikasi_berhasil' 
              : (_isScanning ? 'sedang_memindai' : 'petunjuk_pemindaian')),
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 35),
          GestureDetector(
            onTap: _isSuccess || _isScanning ? null : _startScan,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: _isSuccess
                    ? Colors.green.withOpacity(0.15)
                    : (_isScanning 
                        ? Colors.amber.withOpacity(0.15)
                        : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9))),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isSuccess
                      ? Colors.green
                      : (_isScanning ? Colors.amber : Colors.transparent),
                  width: 3,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isScanning)
                    const SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        strokeWidth: 3,
                      ),
                    ),
                  Icon(
                    _isSuccess 
                        ? Icons.check_circle_rounded 
                        : Icons.fingerprint_rounded,
                    size: 75,
                    color: _isSuccess
                        ? Colors.green
                        : (_isScanning ? Colors.amber : const Color(0xFF002B1D)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 35),
          Text(
            _isSuccess
                ? widget.settings.translate('otentikasi_sukses')
                : (_isScanning 
                    ? widget.settings.translate('memindai_sidik_jari') 
                    : widget.settings.translate('siap_memindai')),
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _isSuccess
                  ? Colors.green
                  : (_isScanning ? Colors.amber : textColor),
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _isSuccess = true;
        });

        widget.settings.toggleBiometric(true);

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.settings.translate('biometrik_berhasil_diaktifkan'),
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF0F5132),
              ),
            );
          }
        });
      }
    });
  }
}
