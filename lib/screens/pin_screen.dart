import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'main_navigation_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  final String _correctPin = '1234'; // PIN Default Anda

  void _onKeypadTap(String val) {
    if (_pin.length < 4) {
      setState(() {
        _pin += val;
      });
    }

    // Jika sudah 4 angka, langsung verifikasi
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), () => _verifyPin());
    }
  }

  void _verifyPin() {
    if (_pin == _correctPin) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const MainNavigationScreen())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Salah! Gunakan "1234"', textAlign: TextAlign.center), 
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E), // Biru Tua Premium
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60), // Menurunkan konten agar tidak terlalu ke atas
            const Icon(Icons.lock_person_outlined, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Masukkan PIN Keamanan',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 40),
            
            // ── INDIKATOR TITIK PIN ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: index < _pin.length ? Colors.cyanAccent : Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38),
                ),
              )),
            ),
            const SizedBox(height: 60),

            // ── KEYPAD ANGKA ──
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    for (var i = 1; i <= 9; i++) _buildKeypadButton(i.toString()),
                    const SizedBox(), // Kosong di kiri nol
                    _buildKeypadButton('0'),
                    _buildBackspaceButton(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String val) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeypadTap(val),
        borderRadius: BorderRadius.circular(100),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white12, width: 2),
            color: Colors.white.withOpacity(0.05),
          ),
          alignment: Alignment.center,
          child: Text(
            val,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_pin.isNotEmpty) {
            setState(() => _pin = _pin.substring(0, _pin.length - 1));
          }
        },
        borderRadius: BorderRadius.circular(100),
        child: Container(
          alignment: Alignment.center,
          child: const Icon(Icons.backspace_outlined, color: Colors.white70, size: 28),
        ),
      ),
    );
  }
}
