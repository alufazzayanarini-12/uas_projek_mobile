import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import 'dart:math';

class EducationFundScreen extends StatefulWidget {
  const EducationFundScreen({super.key});

  @override
  State<EducationFundScreen> createState() => _EducationFundScreenState();
}

class _EducationFundScreenState extends State<EducationFundScreen> {
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Data Jenjang Pendidikan (Mock, bisa disambungkan ke DB nanti)
  List<Map<String, dynamic>> educationStages = [
    {'level': 'SD', 'target': 20000000.0, 'current': 20000000.0, 'status': 'Tercapai', 'isDone': true},
    {'level': 'SMP', 'target': 30000000.0, 'current': 15000000.0, 'status': 'Sedang Berjalan', 'isDone': false},
    {'level': 'SMA', 'target': 40000000.0, 'current': 10000000.0, 'status': 'Belum Dimulai', 'isDone': false},
    {'level': 'Kuliah', 'target': 60000000.0, 'current': 0.0, 'status': 'Target Utama', 'isDone': false},
  ];

  @override
  Widget build(BuildContext context) {
    // MENGAMBIL DATA DARI PROVIDER
    final catProvider = Provider.of<CategoryProvider>(context);
    double mainTarget = catProvider.educationTarget;
    double mainCurrent = catProvider.educationCurrent;
    double mainProgress = mainCurrent / mainTarget;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Dana Pendidikan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── DASHBOARD UTAMA (DATANYA REAL-TIME DARI PROVIDER) ──
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
                      Text('Total Dana Pendidikan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Icon(Icons.school, color: Colors.white, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(fmt.format(mainCurrent), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('Target: ${fmt.format(mainTarget)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(value: mainProgress > 1.0 ? 1.0 : mainProgress, backgroundColor: Colors.white24, color: Colors.yellow[400], minHeight: 8),
                  const SizedBox(height: 10),
                  const Align(alignment: Alignment.centerRight, child: Text('Update Real-time via (+)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('Rencana Jenjang Pendidikan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            ...educationStages.asMap().entries.map((entry) => _buildEducationStepTile(entry.key, entry.value)).toList(),

            const SizedBox(height: 30),
            const Text('Alat Perencanaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            _buildActionCard(Icons.calculate_outlined, 'Kalkulator Biaya Masa Depan', 'Hitung inflasi sekolah (10-15%/thn)', () => _showInflationCalculator(catProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationStepTile(int index, Map<String, dynamic> stage) {
    double progress = (stage['current'] as num) / (stage['target'] as num);
    return GestureDetector(
      onTap: () => _showStageDetail(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
        child: Column(
          children: [
            Row(
              children: [
                Icon(stage['isDone'] ? Icons.check_circle : Icons.radio_button_unchecked, color: stage['isDone'] ? Colors.green : Colors.blue),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(stage['level'], style: const TextStyle(fontWeight: FontWeight.bold)), Text(stage['status'], style: TextStyle(fontSize: 11, color: stage['isDone'] ? Colors.green : Colors.grey))])),
                Text(fmt.format(stage['target']), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
              ],
            ),
            if (!stage['isDone']) ...[const SizedBox(height: 10), LinearProgressIndicator(value: progress, backgroundColor: Colors.blue[50], color: Colors.blue, minHeight: 4)]
          ],
        ),
      ),
    );
  }

  void _showStageDetail(int index) {
    var stage = educationStages[index];
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (context) => Container(padding: const EdgeInsets.all(25), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Detail Jenjang ${stage['level']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Divider(height: 30), _buildInfoRow('Total Target', fmt.format(stage['target'])), _buildInfoRow('Dana Terkumpul', fmt.format(stage['current'])), _buildInfoRow('Kekurangan', fmt.format(stage['target'] - stage['current'])), const SizedBox(height: 20), CheckboxListTile(title: const Text('Tandai sebagai Tercapai', style: TextStyle(fontSize: 14)), value: stage['isDone'], onChanged: (val) { setState(() => educationStages[index]['isDone'] = val); Navigator.pop(context); },),],),),);
  }

  void _showInflationCalculator(CategoryProvider catProvider) {
    double currentCost = 50000000;
    double years = 5;
    double inflationRate = 0.10;
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (context) => StatefulBuilder(builder: (context, setModalState) { double futureCost = currentCost * pow((1 + inflationRate), years); return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 25, top: 25, left: 25, right: 25), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Kalkulator Biaya Masa Depan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 20), TextField(decoration: const InputDecoration(labelText: 'Biaya Saat Ini (Sekarang)', prefixText: 'Rp '), keyboardType: TextInputType.number, onChanged: (v) => setModalState(() => currentCost = double.tryParse(v) ?? 50000000),), const SizedBox(height: 20), Text('Jangka Waktu: ${years.toInt()} Tahun Lagi'), Slider(value: years, min: 1, max: 20, divisions: 19, onChanged: (v) => setModalState(() => years = v)), const Divider(height: 40), Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)), child: Column(children: [const Text('Estimasi Biaya Masa Depan', style: TextStyle(fontSize: 12, color: Colors.blue)), Text(fmt.format(futureCost), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),],),), const SizedBox(height: 25), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () { catProvider.educationTarget = futureCost; catProvider.notifyListeners(); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text('TERAPKAN KE TARGET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),),)],),);},),);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: ListTile(leading: Icon(icon, color: Colors.blue[700]), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)), trailing: const Icon(Icons.chevron_right), onTap: onTap));
  }
}
