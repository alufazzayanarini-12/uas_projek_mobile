import 'package:flutter/material.dart';

class DebtManagementScreen extends StatelessWidget {
  const DebtManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1976D2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manajemen Hutang', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── DAFTAR KONTAK PIUTANG ──
          _buildDebtHeader('Daftar Kontak & Hutang'),
          _buildDebtCard('Nia', 'Rp 2.000.000', 0.6, 'Sisa: Rp 800.000', Colors.orange),
          _buildDebtCard('Wulan', 'Rp 5.000.000', 0.3, 'Sisa: Rp 3.500.000', Colors.red),
          const SizedBox(height: 25),

          // ── JATUH TEMPO (KALENDER RINGKAS) ──
          _buildDebtHeader('Jatuh Tempo Terdekat'),
          _buildDueItem('Nia', '15 Mei 2026', 'Rp 400.000 (Cicilan 3)'),
          _buildDueItem('Wulan', '20 Mei 2026', 'Rp 1.000.000 (Cicilan 1)'),
          const SizedBox(height: 25),

          // ── FITUR TAMBAHAN ──
          _buildDebtHeader('Aksi Lainnya'),
          _buildActionItem(Icons.history, 'Riwayat Cicilan Lengkap'),
          _buildActionItem(Icons.calendar_month, 'Atur Pengingat Kalender'),
          _buildActionItem(Icons.person_add_alt_1, 'Tambah Kontak Baru'),
        ],
      ),
    );
  }

  Widget _buildDebtHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
    );
  }

  Widget _buildDebtCard(String name, String total, double progress, String remaining, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(total, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            minHeight: 8,
          ),
          const SizedBox(height: 10),
          Text(remaining, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDueItem(String name, String date, String amount) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.event, color: Colors.blue),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$date • $amount', style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.notifications_active_outlined, color: Colors.orange, size: 20),
    );
  }

  Widget _buildActionItem(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
