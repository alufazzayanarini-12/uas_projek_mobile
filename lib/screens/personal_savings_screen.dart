import 'package:flutter/material.dart';

class PersonalSavingsScreen extends StatefulWidget {
  const PersonalSavingsScreen({super.key});

  @override
  State<PersonalSavingsScreen> createState() => _PersonalSavingsScreenState();
}

class _PersonalSavingsScreenState extends State<PersonalSavingsScreen> {
  double targetAmount = 5000000;
  double currentSaved = 1500000;

  @override
  Widget build(BuildContext context) {
    double progress = currentSaved / targetAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F3), // Background Pink Muda
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tabungan Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // ── HEADER VISUAL ──
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 20)],
              ),
              child: Column(
                children: [
                  const Icon(Icons.savings_outlined, size: 80, color: Colors.pink),
                  const SizedBox(height: 15),
                  const Text('Target: Beli HP Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('Sisa Rp ${(targetAmount - currentSaved).toInt()} lagi', style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 25),
                  
                  // Progress Bar
                  Stack(
                    children: [
                      Container(height: 12, decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(10))),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(height: 12, decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(10))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(progress * 100).toInt()}% Tercapai', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const Text('Target: Rp 5.000.000', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ── FITUR UTAMA ──
            _buildFeatureTile(Icons.auto_awesome, 'Fitur Round-up', 'Aktif', Colors.pink),
            _buildFeatureTile(Icons.notifications_active_outlined, 'Pengingat Rutin', 'Setiap Minggu', Colors.pink),
            _buildFeatureTile(Icons.history, 'Riwayat Menabung', 'Lihat 12 transaksi', Colors.pink),
            
            const SizedBox(height: 30),

            // ── TOMBOL AKSI ──
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('TAMBAH SALDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
