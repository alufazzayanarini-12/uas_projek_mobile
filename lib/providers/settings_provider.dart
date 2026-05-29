import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class SettingsProvider with ChangeNotifier {
  bool _isBalanceHidden = false;
  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isDarkMode = false;
  String _userName = 'Arini'; 
  String? _profileImagePath;
  double _dailyPocketMoney = 50000.0; // Uang saku harian default
  double _foodLimit = 500000.0; // Limit Makan dan Minum
  double _transportLimit = 150000.0; // Limit Transportasi dan Bensin
  double _monthlyTransactionLimit = 50000000.0; // Limit Transaksi Bulanan
  String _selectedLanguage = 'Bahasa Indonesia';
  String _selectedCurrency = 'Rupiah Indonesia';
  Locale _locale = const Locale('id');

  bool get isBalanceHidden => _isBalanceHidden;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;
  double get dailyPocketMoney => _dailyPocketMoney;
  double get foodLimit => _foodLimit;
  double get transportLimit => _transportLimit;
  double get monthlyTransactionLimit => _monthlyTransactionLimit;
  String get selectedLanguage => _selectedLanguage;
  String get selectedCurrency => _selectedCurrency;
  Locale get locale => _locale;
  
  bool get isPinEnabled => _isAppLockEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isBalanceHidden = prefs.getBool('hide_balance') ?? false;
    _isAppLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _userName = prefs.getString('user_name') ?? 'Arini';
    _profileImagePath = prefs.getString('profile_image_path');
    _dailyPocketMoney = prefs.getDouble('daily_pocket_money') ?? 50000.0;
    _foodLimit = prefs.getDouble('food_limit') ?? 500000.0;
    _transportLimit = prefs.getDouble('transport_limit') ?? 150000.0;
    _monthlyTransactionLimit = prefs.getDouble('monthly_transaction_limit') ?? 50000000.0;
    _selectedLanguage = prefs.getString('selected_language') ?? 'Bahasa Indonesia';
    final localeCode = prefs.getString('locale_code');
    if (localeCode != null && localeCode.isNotEmpty) {
      _locale = Locale(localeCode);
    } else {
      // set locale based on selected language if no saved locale
      _locale = _languageToLocale(_selectedLanguage);
    }
    _selectedCurrency = prefs.getString('selected_currency') ?? 'Rupiah Indonesia';
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    notifyListeners();
  }

  Future<void> setDailyPocketMoney(double value) async {
    _dailyPocketMoney = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('daily_pocket_money', value);
    notifyListeners();
  }

  Future<void> setFoodLimit(double value) async {
    _foodLimit = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('food_limit', value);
    notifyListeners();
  }

  Future<void> setTransportLimit(double value) async {
    _transportLimit = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('transport_limit', value);
    notifyListeners();
  }

  Future<void> setProfileImage(String path) async {
    _profileImagePath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
    notifyListeners();
  }

  Future<void> toggleBalanceVisibility() async {
    _isBalanceHidden = !_isBalanceHidden;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hide_balance', _isBalanceHidden);
    notifyListeners();
  }

  Future<void> toggleAppLock(bool value) async {
    _isAppLockEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', _isAppLockEnabled);
    notifyListeners();
  }

  Future<void> toggleBiometric(bool value) async {
    _isBiometricEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', _isBiometricEnabled);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setMonthlyTransactionLimit(double value) async {
    _monthlyTransactionLimit = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_transaction_limit', value);
    notifyListeners();
  }

  Future<void> setSelectedLanguage(String val) async {
    _selectedLanguage = val;
    _locale = _languageToLocale(val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', val);
    await prefs.setString('locale_code', _locale.languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    // also update selectedLanguage to keep UI in sync
    switch (locale.languageCode) {
      case 'en':
        _selectedLanguage = 'English';
        break;
      case 'ja':
        _selectedLanguage = '日本語';
        break;
      case 'ar':
        _selectedLanguage = 'العربية';
        break;
      default:
        _selectedLanguage = 'Bahasa Indonesia';
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setString('locale_code', _locale.languageCode);
    notifyListeners();
  }

  Locale _languageToLocale(String language) {
    switch (language) {
      case 'English':
        return const Locale('en');
      case '日本語':
        return const Locale('ja');
      case 'العربية':
        return const Locale('ar');
      case 'Bahasa Indonesia':
      default:
        return const Locale('id');
    }
  }

  Future<void> setSelectedCurrency(String val) async {
    _selectedCurrency = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', val);
    notifyListeners();
  }

  ImageProvider getProfileImageProvider() {
    if (_profileImagePath != null && File(_profileImagePath!).existsSync()) {
      return FileImage(File(_profileImagePath!));
    }
    return const AssetImage('assets/profile_arini.jpg');
  }

  // Localization Map for all key texts in the App
  static const Map<String, Map<String, String>> _localizedValues = {
    'Bahasa Indonesia': {
      'sisa_saldo': 'Sisa Saldo',
      'pemasukan': 'Pemasukan',
      'pengeluaran': 'Pengeluaran',
      'tabungan': 'Tabungan',
      'riwayat': 'Riwayat Transaksi',
      'tambah_transaksi': 'Tambah Transaksi',
      'nominal': 'Nominal',
      'simpan': 'Simpan',
      'preferensi': 'Preferensi',
      'dukungan': 'Dukungan',
      'bahasa': 'Bahasa',
      'mata_uang': 'Mata Uang',
      'pengaturan': 'Pengaturan',
      'profil': 'Profil',
      'anggota_premium': 'Anggota Premium',
      'tentang_aplikasi': 'Tentang Aplikasi',
      'kebijakan_privasi': 'Kebijakan Privasi',
      'notifikasi': 'Notifikasi',
      'pengaturan_notifikasi': 'Pengaturan Notifikasi',
      'notifikasi_push': 'Notifikasi Push',
      'pengingat_harian': 'Pengingat Harian',
      'peringatan_anggaran': 'Peringatan Anggaran',
      'mode_gelap': 'Mode Gelap',
      'uang_saku': 'Uang Sakuku',
      'dompet': 'Dompet Digital',
      'kesehatan_keuangan': 'Kesehatan Keuangan',
      'rencana_keuangan': 'Rencana Keuangan',
      'pilih_kategori': 'Pilih Kategori',
      'keterangan': 'Keterangan',
      'tanggal': 'Tanggal',
      'akun_asal': 'Akun Asal',
      'selesai': 'Selesai',
      'atur_limit': 'Atur Limit',
      'target_anda': 'Target Anda',
      'dana_darurat': 'Dana Darurat',
      'jaring_pengaman': 'Jaring Pengaman Finansial',
      'dialokasikan': 'Dialokasikan',
      'laptop_baru': 'Laptop Baru',
      'buku_nw': 'Buku NW',
      'edit': 'Edit',
      'hapus': 'Hapus',
      'target_label': 'Target',
      'total_saldo_anda': 'Total Saldo Anda',
      'catat_setoran': 'Catat Setoran',
      'proyeksi_bulanan': 'Proyeksi Bulanan',
      'berdasarkan_target_12_bulan': 'Berdasarkan target 12 bulan.',
      'estimasi_selesai': 'Estimasi Selesai',
      'dalam_bulan': 'Dalam {months} Bulan',
      'simpan_target': 'Simpan Target',
      'nama_target': 'Nama Target',
      'nominal_target': 'Nominal Target (Rp)',
      'kategori_target': 'Kategori Target',
      'target_waktu': 'Target Waktu',
      'kategori_tabungan': 'Tabungan',
      'kategori_investasi': 'Investasi',
      'edit_target': 'Edit Target',
      'buat_target_baru': 'Buat Target Baru',
      'kategori_pembelian': 'Pembelian',
      'kategori_darurat': 'Darurat',
      'total_label': 'Total',
      'nominal_harus_diisi': 'Nominal harus diisi',
      'nama_dan_nominal_harus_diisi': 'Nama dan Nominal harus diisi',
      'contoh_nama_target': 'Contoh: Beli Laptop Baru',
      'setoran_berhasil_dicatat': 'Setoran berhasil dicatat!',
      'contoh_setoran_tidak_disimpan': 'Ini hanya contoh. Setoran tidak dapat disimpan.',
      'beranda': 'Beranda',
      'statistik': 'Statistik',
      'tambah': 'Tambah',
      'laporan': 'Laporan',
      'tabunganku': 'Tabunganku',
      'pilih_aksi': 'Pilih Aksi',
      'pilih_aksi_subtitle': 'Kelola keuangan Anda dengan kontrol penuh.',
      'audit_financial': 'Audit Finansial',
      'audit_financial_subtitle': 'Cek kesehatan keuangan Anda.',
      'debt_management': 'Manajemen Utang',
      'debt_management_subtitle': 'Kelola catatan hutang & piutang Anda.',
      'tips_text': 'Tips: Mengatur otomatisasi membantu Anda berhemat 15% lebih banyak setiap bulan.',
      'pola_pengeluaran': 'Pola Pengeluaran',
      'pengeluaran_harian': 'Pengeluaran harian',
      'atur_uang_saku_harian': 'Atur Uang Saku Harian',
      'konfig_uang_saku_deskripsi': 'Konfigurasikan nominal uang saku harian baru Anda.',
      'simpan_uang_saku': 'Simpan Uang Saku',
      'estimasi_alokasi_bulanan': 'Estimasi alokasi bulanan berdasarkan uang saku harian Anda.',
      'total_aliran_logika': 'Total aliran-logika',
      'nominal_baru': 'Nominal Baru',
      'uang_saku_diperbarui': 'Uang saku harian diperbarui ke {amount}!',
      'laporan_bulanan': 'Laporan Bulanan',
      'laporan_keuangan': 'Laporan Keuangan',
      'sisa_saldo_bersih': 'Sisa Saldo Bersih',
      'rincian_pengeluaran': 'Rincian Pengeluaran',
      'makan_dan_minum': 'Makan dan Minum',
      'transportasi_dan_bensin': 'Transportasi dan Bensin',
      'lain_lain': 'Lain-lain',
      'analisis_bulanan': 'Analisis Bulanan',
      'analisis_bulanan_deskripsi': 'Hebat! Pengeluaran Anda di bulan ini turun 15% dibanding rata-rata bulan lalu. Sisa saldo {balance} ideal dialokasikan langsung ke Tabunganku.',
      'laporan_berhasil_unduh': 'Laporan {month} berhasil diunduh sebagai PDF!',
      'unduh_laporan_pdf': 'Unduh Laporan (PDF)',
      'pilih_format_unduh': 'Pilih format file untuk mengunduh laporan keuangan Anda secara lengkap.',
      'laporan_rapi_siap_cetak': 'Laporan rapi siap cetak dan mudah dibagikan',
      'laporan_berhasil_ekspor': 'Laporan keuangan format {format} telah berhasil diekspor ke folder Unduhan perangkat Anda.',
      'akun': 'Akun',
      'pengaturan_akun': 'Pengaturan Akun',
      'keamanan': 'Keamanan',
      'metode_pembayaran': 'Metode Pembayaran',
      'dikembangkan_oleh': 'Dikembangkan oleh:',
      'versi_aplikasi': 'Versi Aplikasi 2.1.0',
      'hak_cipta': 'Hak Cipta © 2026 Tabunganku.\nSemua Hak Dilindungi.',
      'jumlah_nominal': 'Jumlah Nominal',
      'kartu_kredit': 'Kartu Kredit',
      'kategori': 'Kategori',
      'simpan_transaksi': 'Simpan Transaksi',
      'persentase_pengeluaran': '{percentage}% dari pengeluaran',
      'mingguan': 'Mingguan',
      'bulanan': 'Bulanan',
      'tahunan': 'Tahunan',
      'tren_signifikan': 'Tren Signifikan',
      'sisa_tabungan': 'Sisa Tabungan',
      'tabungan_sehat_desc': 'Tabungan Anda sehat. Capai 65% dari target bulanan.',
      'target_tabungan': 'Target Tabungan',
      'harian': 'Harian',
    },
    'English': {
      'sisa_saldo': 'Remaining Balance',
      'pemasukan': 'Income',
      'pengeluaran': 'Expense',
      'tabungan': 'Savings',
      'riwayat': 'Transaction History',
      'tambah_transaksi': 'Add Transaction',
      'nominal': 'Amount',
      'simpan': 'Save',
      'preferensi': 'Preferences',
      'dukungan': 'Support',
      'bahasa': 'Language',
      'mata_uang': 'Currency',
      'pengaturan': 'Settings',
      'profil': 'Profile',
      'anggota_premium': 'Premium Member',
      'tentang_aplikasi': 'About Application',
      'kebijakan_privasi': 'Privacy Policy',
      'notifikasi': 'Notifications',
      'pengaturan_notifikasi': 'Notification Settings',
      'notifikasi_push': 'Push Notifications',
      'pengingat_harian': 'Daily Reminder',
      'peringatan_anggaran': 'Budget Warning',
      'mode_gelap': 'Dark Mode',
      'uang_saku': 'My Pocket Money',
      'dompet': 'Digital Wallet',
      'kesehatan_keuangan': 'Financial Health',
      'rencana_keuangan': 'Financial Plan',
      'pilih_kategori': 'Select Category',
      'keterangan': 'Description',
      'tanggal': 'Date',
      'akun_asal': 'Source Account',
      'selesai': 'Done',
      'atur_limit': 'Set Limit',
      'target_anda': 'Your Goals',
      'dana_darurat': 'Emergency Fund',
      'jaring_pengaman': 'Financial Safety Net',
      'dialokasikan': 'Allocated',
      'laptop_baru': 'New Laptop',
      'buku_nw': 'Books NW',
      'edit': 'Edit',
      'hapus': 'Delete',
      'target_label': 'Target',
      'total_saldo_anda': 'Your Total Balance',
      'catat_setoran': 'Record Deposit',
      'proyeksi_bulanan': 'Monthly Projection',
      'berdasarkan_target_12_bulan': 'Based on a 12-month target.',
      'estimasi_selesai': 'Estimated Completion',
      'dalam_bulan': 'In {months} Months',
      'nama_target': 'Goal Name',
      'nominal_target': 'Target Amount (Rp)',
      'kategori_target': 'Goal Category',
      'target_waktu': 'Target Time',
      'kategori_tabungan': 'Savings',
      'kategori_investasi': 'Investment',
      'edit_target': 'Edit Goal',
      'buat_target_baru': 'Create New Goal',
      'kategori_pembelian': 'Purchase',
      'kategori_darurat': 'Emergency',
      'total_label': 'Total',
      'nominal_harus_diisi': 'Amount must be entered',
      'nama_dan_nominal_harus_diisi': 'Name and amount must be entered',
      'contoh_nama_target': 'Example: Buy a new laptop',
      'simpan_target': 'Save Target',
      'setoran_berhasil_dicatat': 'Deposit recorded successfully!',
      'contoh_setoran_tidak_disimpan': 'This is only a sample. Deposits cannot be saved.',
      'beranda': 'Home',
      'statistik': 'Statistics',
      'tambah': 'Add',
      'laporan': 'Reports',
      'tabunganku': 'My Savings',
      'pilih_aksi': 'Choose Action',
      'pilih_aksi_subtitle': 'Manage your finances with full control.',
      'audit_financial': 'Financial Audit',
      'audit_financial_subtitle': 'Check your financial health.',
      'debt_management': 'Debt Management',
      'debt_management_subtitle': 'Manage your debt & receivables records.',
      'tips_text': 'Tip: Automating savings can help you save 15% more monthly.',
      'pola_pengeluaran': 'Spending Patterns',
      'pengeluaran_harian': 'Daily Expenses',
      'atur_uang_saku_harian': 'Set Daily Pocket Money',
      'konfig_uang_saku_deskripsi': 'Configure your new daily pocket money amount.',
      'simpan_uang_saku': 'Save Pocket Money',
      'estimasi_alokasi_bulanan': 'Estimated monthly allocation based on your daily pocket money.',
      'total_aliran_logika': 'Total flow logic',
      'nominal_baru': 'New Amount',
      'uang_saku_diperbarui': 'Daily pocket money updated to {amount}!',
      'laporan_bulanan': 'Monthly Report',
      'laporan_keuangan': 'Financial Report',
      'sisa_saldo_bersih': 'Net Remaining Balance',
      'rincian_pengeluaran': 'Expense Breakdown',
      'makan_dan_minum': 'Food & Drinks',
      'transportasi_dan_bensin': 'Transportation & Fuel',
      'lain_lain': 'Others',
      'analisis_bulanan': 'Monthly Analysis',
      'analisis_bulanan_deskripsi': 'Great! Your spending this month is 15% lower than last month. The remaining balance of {balance} is ideally allocated directly to Tabunganku.',
      'laporan_berhasil_unduh': 'Report for {month} was downloaded as PDF!',
      'unduh_laporan_pdf': 'Download Report (PDF)',
      'pilih_format_unduh': 'Choose a file format to download your full financial report.',
      'laporan_rapi_siap_cetak': 'Printer-ready reports that are easy to share',
      'laporan_berhasil_ekspor': 'Financial report in {format} has been exported to your device Downloads folder.',
      'akun': 'Account',
      'pengaturan_akun': 'Account Settings',
      'keamanan': 'Security',
      'metode_pembayaran': 'Payment Methods',
      'dikembangkan_oleh': 'Developed by:',
      'versi_aplikasi': 'App Version 2.1.0',
      'hak_cipta': 'Copyright © 2026 Tabunganku.\nAll Rights Reserved.',
      'jumlah_nominal': 'Amount',
      'kartu_kredit': 'Credit Card',
      'kategori': 'Category',
      'simpan_transaksi': 'Save Transaction',
      'persentase_pengeluaran': '{percentage}% of expenses',
      'mingguan': 'Weekly',
      'bulanan': 'Monthly',
      'tahunan': 'Yearly',
      'tren_signifikan': 'Significant Trend',
      'sisa_tabungan': 'Remaining Savings',
      'tabungan_sehat_desc': 'Your savings are healthy. Reach 65% of monthly target.',
      'target_tabungan': 'Savings Target',
      'harian': 'Daily',
    },
    '日本語': {
      'sisa_saldo': '残高',
      'pemasukan': '収入',
      'pengeluaran': '支出',
      'tabungan': '貯金',
      'riwayat': '取引履歴',
      'tambah_transaksi': '取引を追加',
      'nominal': '金額',
      'simpan': '保存',
      'preferensi': '設定優先',
      'dukungan': 'サポート',
      'bahasa': '言語',
      'mata_uang': '通貨',
      'pengaturan': '設定',
      'profil': 'プロフィール',
      'anggota_premium': 'プレミアム会員',
      'tentang_aplikasi': 'アプリについて',
      'kebijakan_privasi': '個人情報保護方針',
      'notifikasi': '通知',
      'pengaturan_notifikasi': '通知の設定',
      'notifikasi_push': 'プッシュ通知',
      'pengingat_harian': '毎日のリマインダー',
      'peringatan_anggaran': '予算警告',
      'mode_gelap': 'ダークモード',
      'uang_saku': 'お小遣い',
      'dompet': 'デジタル財布',
      'kesehatan_keuangan': '財務健康',
      'rencana_keuangan': '財務計画',
      'pilih_kategori': 'カテゴリを選択',
      'keterangan': '説明',
      'tanggal': '日付',
      'akun_asal': '送金元アカウント',
      'selesai': '完了',
      'atur_limit': '上限設定',
      'target_anda': 'あなたの目標',
      'dana_darurat': '緊急資金',
      'jaring_pengaman': '財務安全ネット',
      'dialokasikan': '配分済み',
      'laptop_baru': '新しいノートPC',
      'buku_nw': '本 NW',
      'edit': '編集',
      'hapus': '削除',
      'target_label': '目標',
      'total_saldo_anda': 'あなたの残高合計',
      'catat_setoran': '入金を記録',
      'proyeksi_bulanan': '月次予測',
      'berdasarkan_target_12_bulan': '12か月の目標に基づく。',
      'estimasi_selesai': '完了予測',
      'dalam_bulan': '{months} か月で',
      'simpan_target': '目標を保存',
      'nama_target': '目標名',
      'nominal_target': '目標金額 (Rp)',
      'kategori_target': '目標カテゴリ',
      'target_waktu': '目標期間',
      'kategori_tabungan': '貯蓄',
      'kategori_investasi': '投資',
      'edit_target': '目標を編集',
      'buat_target_baru': '新しい目標を作成',
      'kategori_pembelian': '購入',
      'kategori_darurat': '緊急',
      'total_label': '合計',
      'nominal_harus_diisi': '金額を入力する必要があります',
      'nama_dan_nominal_harus_diisi': '名前と金額を入力する必要があります',
      'contoh_nama_target': '例: 新しいノートパソコンを購入',
      'setoran_berhasil_dicatat': '入金が正常に記録されました！',
      'contoh_setoran_tidak_disimpan': 'これはサンプルです。入金は保存できません。',
      'beranda': 'ホーム',
      'statistik': '統計',
      'tambah': '追加',
      'laporan': 'レポート',
      'tabunganku': '私の貯金',
      'pilih_aksi': 'アクションを選択',
      'pilih_aksi_subtitle': '完全なコントロールで財務を管理します。',
      'audit_financial': '財務監査',
      'audit_financial_subtitle': 'あなたの財務状況をチェックします。',
      'debt_management': '債務管理',
      'debt_management_subtitle': '債務と債権の管理。',
      'tips_text': 'ヒント: 自動化により毎月15%多く節約できます。',
      'pola_pengeluaran': '支出パターン',
      'pengeluaran_harian': '日次支出',
      'atur_uang_saku_harian': '日次お小遣いを設定',
      'konfig_uang_saku_deskripsi': '新しい日次お小遣いの金額を設定してください。',
      'simpan_uang_saku': 'お小遣いを保存',
      'estimasi_alokasi_bulanan': '日次お小遣いに基づく月間配分の推定。',
      'total_aliran_logika': '合計フローのロジック',
      'nominal_baru': '新しい金額',
      'uang_saku_diperbarui': '日次お小遣いが {amount} に更新されました！',
      'laporan_bulanan': '月次レポート',
      'laporan_keuangan': '財務レポート',
      'sisa_saldo_bersih': '純残高',
      'rincian_pengeluaran': '支出の内訳',
      'makan_dan_minum': '食費・飲料',
      'transportasi_dan_bensin': '交通費・燃料',
      'lain_lain': 'その他',
      'analisis_bulanan': '月次分析',
      'analisis_bulanan_deskripsi': '素晴らしい！今月の支出は先月平均より15％少なく、残高 {balance} は Tabunganku に直接配分するのに理想的です。',
      'laporan_berhasil_unduh': '{month} のレポートが PDF としてダウンロードされました！',
      'unduh_laporan_pdf': 'レポートをダウンロード (PDF)',
      'pilih_format_unduh': '完全な財務レポートをダウンロードするファイル形式を選択してください。',
      'laporan_rapi_siap_cetak': '印刷準備ができた共有しやすいレポート',
      'laporan_berhasil_ekspor': '{format} 形式の財務レポートがダウンロードフォルダにエクスポートされました。',
      'akun': 'アカウント',
      'pengaturan_akun': 'アカウント設定',
      'keamanan': 'セキュリティ',
      'metode_pembayaran': '支払い方法',
      'dikembangkan_oleh': '開発者:',
      'versi_aplikasi': 'アプリバージョン 2.1.0',
      'hak_cipta': '著作権 © 2026 Tabunganku。\n全著作権所有。',
      'jumlah_nominal': '金額',
      'kartu_kredit': 'クレジットカード',
      'kategori': 'カテゴリ',
      'simpan_transaksi': '取引を保存',
      'persentase_pengeluaran': '支出の {percentage}%',
      'mingguan': '週次',
      'bulanan': '月次',
      'tahunan': '年次',
      'tren_signifikan': '顕著な傾向',
      'sisa_tabungan': '貯金残高',
      'tabungan_sehat_desc': '貯金は健全です。月目標の65%を達成。',
      'target_tabungan': '貯金目標',
      'harian': '日次',
    },
    'العربية': {
      'sisa_saldo': 'الرصيد المتبقي',
      'pemasukan': 'الدخل',
      'pengeluaran': 'المصاريف',
      'tabungan': 'المدخرات',
      'riwayat': 'سجل المعاملات',
      'tambah_transaksi': 'إضافة معاملة',
      'nominal': 'المبلغ',
      'simpan': 'حفظ',
      'preferensi': 'التفضيلات',
      'dukungan': 'الدعم',
      'bahasa': 'اللغة',
      'mata_uang': 'العملة',
      'pengaturan': 'الإعدادات',
      'profil': 'الملف الشخصي',
      'anggota_premium': 'عضو مميز',
      'tentang_aplikasi': 'عن التطبيق',
      'kebijakan_privasi': 'سياسة الخصوصية',
      'notifikasi': 'الإشعارات',
      'pengaturan_notifikasi': 'إعدادات الإشعارات',
      'notifikasi_push': 'إشعارات الدفع',
      'pengingat_harian': 'تذكير يومي',
      'peringatan_anggaran': 'تحذير الميزانية',
      'mode_gelap': 'الوضع الداكن',
      'uang_saku': 'مصروفي الخاص',
      'dompet': 'المحفظة الرقمية',
      'kesehatan_keuangan': 'الصحة المالية',
      'rencana_keuangan': 'الخطة المالية',
      'pilih_kategori': 'اختر الفئة',
      'keterangan': 'الوصف',
      'tanggal': 'التاريخ',
      'akun_asal': 'الحساب المصدر',
      'selesai': 'تم',
      'atur_limit': 'تعيين الحد',
      'target_anda': 'أهدافك',
      'dana_darurat': 'صندوق الطوارئ',
      'jaring_pengaman': 'شبكة الأمان المالي',
      'dialokasikan': 'مخصص',
      'laptop_baru': 'كمبيوتر محمول جديد',
      'buku_nw': 'كتب NW',
      'contoh_snack': 'هذا مجرد مثال. أضف أهدافك الحقيقية.',
      'edit': 'تعديل',
      'hapus': 'حذف',
      'target_label': 'الهدف',
      'total_saldo_anda': 'إجمالي رصيدك',
      'catat_setoran': 'تسجيل الإيداع',
      'proyeksi_bulanan': 'التوقع الشهري',
      'berdasarkan_target_12_bulan': 'بناءً على هدف 12 شهرًا.',
      'estimasi_selesai': 'الانتهاء المتوقع',
      'dalam_bulan': 'في {months} شهر',
      'simpan_target': 'حفظ الهدف',
      'nama_target': 'اسم الهدف',
      'nominal_target': 'المبلغ المستهدف (Rp)',
      'kategori_target': 'فئة الهدف',
      'target_waktu': 'وقت الهدف',
      'kategori_tabungan': 'المدخرات',
      'kategori_investasi': 'الاستثمار',
      'edit_target': 'تحرير الهدف',
      'buat_target_baru': 'إنشاء هدف جديد',
      'kategori_pembelian': 'الشراء',
      'kategori_darurat': 'الطوارئ',
      'total_label': 'الإجمالي',
      'nominal_harus_diisi': 'يجب إدخال المبلغ',
      'nama_dan_nominal_harus_diisi': 'يجب إدخال الاسم والمبلغ',
      'contoh_nama_target': 'مثال: شراء كمبيوتر محمول جديد',
      'setoran_berhasil_dicatat': 'تم تسجيل الإيداع بنجاح!',
      'contoh_setoran_tidak_disimpan': 'هذا مجرد مثال. لا يمكن حفظ الإيداع.',
      'beranda': 'الصفحة الرئيسية',
      'statistik': 'الإحصائيات',
      'tambah': 'إضافة',
      'laporan': 'التقارير',
      'tabunganku': 'مدخراتي',
      'pilih_aksi': 'اختر إجراء',
      'pilih_aksi_subtitle': 'قم بإدارة مواردك المالية بتحكم كامل.',
      'audit_financial': 'تدقيق مالي',
      'audit_financial_subtitle': 'تحقق من صحة وضعك المالي.',
      'debt_management': 'إدارة الديون',
      'debt_management_subtitle': 'إدارة سجلات الديون والمستحقات.',
      'tips_text': 'نصيحة: التلقائية تساعدك على الادخار بنسبة 15% أكثر شهريًا.',
      'pola_pengeluaran': 'نمط الإنفاق',
      'pengeluaran_harian': 'المصاريف اليومية',
      'atur_uang_saku_harian': 'تعيين المصروف اليومي',
      'konfig_uang_saku_deskripsi': 'قم بتكوين قيمة المصروف اليومي الجديد الخاص بك.',
      'simpan_uang_saku': 'حفظ المصروف',
      'estimasi_alokasi_bulanan': 'تقدير التخصيص الشهري بناءً على المصروف اليومي.',
      'total_aliran_logika': 'إجمالي منطق التدفق',
      'nominal_baru': 'المبلغ الجديد',
      'uang_saku_diperbarui': 'تم تحديث المصروف اليومي إلى {amount}!',
      'laporan_bulanan': 'التقرير الشهري',
      'laporan_keuangan': 'التقرير المالي',
      'sisa_saldo_bersih': 'الرصيد المتبقي الصافي',
      'rincian_pengeluaran': 'تفصيل المصروفات',
      'makan_dan_minum': 'الطعام والمشروبات',
      'transportasi_dan_bensin': 'النقل والوقود',
      'lain_lain': 'أخرى',
      'analisis_bulanan': 'التحليل الشهري',
      'analisis_bulanan_deskripsi': 'رائع! إنفاقك هذا الشهر أقل بنسبة 15٪ من الشهر الماضي. الرصيد المتبقي {balance} من المثالي تخصيصه مباشرة إلى Tabunganku.',
      'laporan_berhasil_unduh': 'تم تنزيل تقرير {month} كملف PDF!',
      'unduh_laporan_pdf': 'تنزيل التقرير (PDF)',
      'pilih_format_unduh': 'اختر تنسيق الملف لتنزيل تقريرك المالي الكامل.',
      'laporan_rapi_siap_cetak': 'تقارير جاهزة للطباعة وسهلة المشاركة',
      'laporan_berhasil_ekspor': 'تم تصدير التقرير المالي بصيغة {format} إلى مجلد التنزيلات على جهازك.',
      'akun': 'الحساب',
      'pengaturan_akun': 'إعدادات الحساب',
      'keamanan': 'الأمان',
      'metode_pembayaran': 'طرق الدفع',
      'dikembangkan_oleh': 'تم التطوير بواسطة:',
      'versi_aplikasi': 'إصدار التطبيق 2.1.0',
      'hak_cipta': 'حقوق النشر © 2026 Tabunganku.\nجميع الحقوق محفوظة.',
      'jumlah_nominal': 'المبلغ',
      'kartu_kredit': 'بطاقة الائتمان',
      'kategori': 'الفئة',
      'simpan_transaksi': 'حفظ المعاملة',
      'persentase_pengeluaran': '{percentage}% من المصاريف',
      'mingguan': 'أسبوعي',
      'bulanan': 'شهري',
      'tahunan': 'سنوي',
      'tren_signifikan': 'اتجاه ملحوظ',
      'sisa_tabungan': 'المدخرات المتبقية',
      'tabungan_sehat_desc': 'مدخراتك بصحة جيدة. تم تحقيق 65٪ من الهدف الشهري.',
      'target_tabungan': 'هدف الادخار',
      'harian': 'يومي',
    }
  };

  String translate(String key) {
    return _localizedValues[_selectedLanguage]?[key] ?? 
           _localizedValues['Bahasa Indonesia']?[key] ?? 
           key;
  }

  String formatCurrency(double amount) {
    String symbol = 'Rp';
    String locale = 'id';
    switch (_selectedCurrency) {
      case 'Rupiah Indonesia':
        symbol = 'Rp';
        locale = 'id';
        break;
      case 'US Dollar':
        symbol = '\$';
        locale = 'en_US';
        break;
      case 'Euro':
        symbol = '€';
        locale = 'de_DE';
        break;
      case 'Japanese Yen':
        symbol = '¥';
        locale = 'ja_JP';
        break;
      case 'Saudi Riyal':
        symbol = '﷼';
        locale = 'ar_SA';
        break;
      case 'Ringgit Malaysia':
        symbol = 'RM';
        locale = 'ms_MY';
        break;
      default:
        symbol = 'Rp';
        locale = 'id';
    }
    return NumberFormat.currency(
      locale: locale,
      symbol: '$symbol ',
      decimalDigits: 0,
    ).format(amount);
  }
}
