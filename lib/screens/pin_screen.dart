import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  const PinScreen({super.key, this.isSetup = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _enteredPin = '';
  String? _savedPin;
  String _message = 'Masukkan PIN';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSavedPin();
  }

  Future<void> _checkSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    final isSecurityEnabled = prefs.getBool('app_lock_enabled') ?? false; // Cek apakah kunci aktif
    
    setState(() {
      _savedPin = prefs.getString('app_pin');
      _isLoading = false;

      // Jika tidak ada PIN atau kunci aplikasi dimatikan, langsung masuk
      if ((_savedPin == null && !widget.isSetup) || (!isSecurityEnabled && !widget.isSetup)) {
        _navigateToHome();
        return;
      }

      if (_savedPin == null) {
        _message = 'Buat PIN Baru';
      }
    });
  }

  void _onNumberPressed(String number) async {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
      });

      if (_enteredPin.length == 4) {
        if (_savedPin == null || widget.isSetup) {
          // Setting up new PIN
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('app_pin', _enteredPin);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN Berhasil Disimpan')));
          _navigateToHome();
        } else {
          // Validating PIN
          if (_enteredPin == _savedPin) {
            _navigateToHome();
          } else {
            setState(() {
              _enteredPin = '';
              _message = 'PIN Salah! Coba lagi.';
            });
          }
        }
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF03045E),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              _message,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length ? Colors.white : Colors.white24,
                  ),
                );
              }),
            ),
            const SizedBox(height: 60),
            _buildNumberPad(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3']),
        _buildNumberRow(['4', '5', '6']),
        _buildNumberRow(['7', '8', '9']),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBiometricButton(), // Tambahkan tombol sidik jari di sini
            _buildNumberButton('0'),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((n) => _buildNumberButton(n)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      margin: const EdgeInsets.all(12),
      width: 70,
      height: 70,
      child: number.isEmpty
          ? null
          : TextButton(
              onPressed: () => _onNumberPressed(number),
              style: TextButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.white12,
              ),
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  Widget _buildBiometricButton() {
    return Container(
      margin: const EdgeInsets.all(12),
      width: 70,
      height: 70,
      child: IconButton(
        onPressed: _authenticateBiometric,
        icon: const Icon(Icons.fingerprint, color: Colors.white, size: 40),
      ),
    );
  }

  Future<void> _authenticateBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    final isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (!isBiometricEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktifkan Biometrik di Pengaturan terlebih dahulu')),
      );
      return;
    }

    // Simulasi Berhasil (Karena paket local_auth butuh setup manual di Android)
    // Jika Anda sudah instal local_auth, bagian ini bisa diganti dengan fungsi aslinya
    _navigateToHome();
  }

  Widget _buildDeleteButton() {
    return Container(
      margin: const EdgeInsets.all(12),
      width: 70,
      height: 70,
      child: IconButton(
        onPressed: _onDeletePressed,
        icon: const Icon(Icons.backspace_outlined, color: Colors.white),
        iconSize: 32,
      ),
    );
  }
}
