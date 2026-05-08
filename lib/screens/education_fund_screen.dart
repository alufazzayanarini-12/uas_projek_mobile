import 'package:flutter/material.dart';

class EducationFundScreen extends StatefulWidget {
  const EducationFundScreen({super.key});

  @override
  State<EducationFundScreen> createState() => _EducationFundScreenState();
}

class _EducationFundScreenState extends State<EducationFundScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Background Biru Muda
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Dana Pendidikan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── DASHBOARD PENCAPAIAN ──
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15)],
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Target: Kuliah Anak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Icon(Icons.school, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Rp 45.000.000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const Text('Terkumpul dari Rp 150.000.000', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(value: 0.3, backgroundColor: Colors.white24, color: Colors.yellow[400]),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('8 Tahun Lagi Menuju Target', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ── FITUR KHUSUS PENDIDIKAN ──
            const Text('Rencana Pendidikan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            _buildEducationStep('SD', 'Tercapai', true),
            _buildEducationStep('SMP', 'Sedang Berjalan', false),
            _buildEducationStep('SMA', 'Belum Dimulai', false),
            _buildEducationStep('Kuliah', 'Target Utama', false),

            const SizedBox(height: 30),

            // ── FITUR KALKULATOR & KUNCI ──
            _buildOptionCard(Icons.calculate_outlined, 'Kalkulator Biaya Masa Depan', 'Estimasi inflasi 10%/tahun'),
            _buildOptionCard(Icons.lock_clock_outlined, 'Kunci Tabungan (Lock)', 'Saldo tidak bisa ditarik s/d 2028'),
            _buildOptionCard(Icons.trending_up, 'Simulasi Investasi', 'Potensi pertumbuhan 6% per tahun'),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('LIHAT RENCANA MASA DEPAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationStep(String level, String status, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? Colors.green : Colors.blue),
          const SizedBox(width: 15),
          Text(level, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(status, style: TextStyle(fontSize: 12, color: isDone ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOptionCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[700]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onTap: () {},
      ),
    );
  }
}
