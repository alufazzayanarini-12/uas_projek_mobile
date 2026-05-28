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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', val);
    notifyListeners();
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
    }
  };

  String translate(String key) {
    return _localizedValues[_selectedLanguage]?[key] ?? _localizedValues['Bahasa Indonesia']![key]!;
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
