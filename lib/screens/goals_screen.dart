import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _isRuleEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        titleSpacing: 25,
        title: Row(
          children: [
            Text(
              'MindMoney',
              style: GoogleFonts.outfit(
                color: const Color(0xFF002B1D),
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ],
        ),
        actions: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=man_mindmoney'),
          ),
          const SizedBox(width: 10),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Color(0xFF002B1D)), onPressed: () {}),
          const SizedBox(width: 15),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                Text(
                  'Mesin Aturan',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B1D),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 20),
                  label: Text('Aturan Baru', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002B1D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(160, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),
                _buildMainRuleCard(),
                const SizedBox(height: 25),
                _buildAutomationHealthCard(),
                const SizedBox(height: 150),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: _buildLightningFab(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainRuleCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFD4E3E1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.psychology_outlined, color: Color(0xFF002B1D), size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logika Penyangga\nDarurat',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D), height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aktif • Terakhir dieksekusi 2 jam yang lalu',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE8EEF9), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.withOpacity(0.2))),
                    child: Text('SYSTEM_01', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                  ),
                  const SizedBox(height: 8),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _isRuleEnabled,
                      onChanged: (v) => setState(() => _isRuleEnabled = v),
                      activeColor: const Color(0xFF002B1D),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildIfThenLogic(),
        ],
      ),
    );
  }

  Widget _buildIfThenLogic() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: const Color(0xFFE8EEF9), borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text('IF', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.blue[900])),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text('Saldo > ', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey)),
                    Text('Rp 5.000.000', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                    const Spacer(),
                    const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 30,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 19),
          child: Container(width: 2, height: 30, color: Colors.grey[200]),
        ),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: const Color(0xFF002B1D), borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text('THEN', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFEDF5F2), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    const Icon(Icons.move_up_rounded, size: 18, color: Color(0xFF002B1D)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF002B1D)),
                          children: [
                            const TextSpan(text: 'Pindahkan '),
                            TextSpan(text: 'Rp 500.000 ', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: 'ke '),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFCADBD9), borderRadius: BorderRadius.circular(20)),
                      child: Text('Dana Darurat', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAutomationHealthCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kesehatan Otomatisasi', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL AKSI', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  Text('142', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Akurasi', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  Text('99.8%', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[100]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(painter: WavePainter()),
          ),
        ],
      ),
    );
  }

  Widget _buildLightningFab() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF002B1D),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: const Color(0xFF002B1D).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: const Icon(Icons.bolt, color: Colors.white, size: 35),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFF002B1D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    var path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.2, size.width * 0.6, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.8, size.height * 1.2, size.width * 0.9, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
