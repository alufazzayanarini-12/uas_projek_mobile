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
  String _phoneNumber = '+62 812 3456 7890';
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
  String get phoneNumber => _phoneNumber;
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
    _phoneNumber = prefs.getString('user_phone') ?? '+62 812 3456 7890';
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

  Future<void> setPhoneNumber(String phone) async {
    _phoneNumber = phone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);
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
      'sisa_uang_tabungan': 'Sisa Uang Tabungan',
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
      'pilih_bahasa': 'Pilih Bahasa',
      'bahasa_tersedia': 'BAHASA TERSEDIA',
      'bahasa_diubah_ke': 'Bahasa diubah ke {language}!',
      'lainnya': 'LAINNYA',
      'tema_gelap_aktif': 'Tema Gelap Aktif',
      'tema_terang_aktif': 'Tema Terang Aktif',
      'membuka_rincian': 'Membuka rincian: {title}',
      'nama_lengkap': 'Nama Lengkap',
      'email': 'Email',
      'nomor_telepon': 'Nomor Telepon',
      'perangkat_terhubung': 'PERANGKAT TERHUBUNG',
      'aktif_sekarang': 'Aktif sekarang',
      'terakhir_aktif_2_jam_lalu': 'Terakhir aktif 2 jam lalu',
      'hapus': 'Hapus',
      'pengaturan_umum': 'Pengaturan Umum',
      'akun_dan_keamanan': 'AKUN & KEAMANAN',
      'informasi_pribadi': 'Informasi Pribadi',
      'nama_email_telepon': 'Nama, Email, Telepon',
      'kata_sandi_keamanan': 'Kata Sandi & Keamanan',
      'pin_sidik_jari': 'PIN, Sidik Jari',
      'manajemen_rekening': 'Manajemen Rekening',
      'rekening_terhubung': '2 Rekening Terhubung',
      'preferensi_aplikasi': 'PREFERENSI APLIKASI',
      'pengingat_harian_aktif': 'Pengingat Harian Aktif',
      'pusat_bantuan': 'Pusat Bantuan',
      'faq_dan_kontak_dukung': 'FAQ & Kontak Dukungan',
      'keluar_dari_akun': 'Keluar dari Akun',
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
      'dana_darurat': 'Mulai Menabung',
      'jaring_pengaman': 'Jaring Pengaman Finansial',
      'dialokasikan': 'Dialokasikan',
      'laptop_baru': 'Laptop Baru',
      'buku_nw': 'Buku NW',
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
      'financial_audit_snackbar': 'Halaman ini mengevaluasi kesehatan finansial berdasarkan tabungan Rp {target} Anda.',
      'status_need_improvement': 'Perlu Ditingkatkan',
      'status_very_healthy': 'Sangat Sehat',
      'status_healthy': 'Sehat',
      'status_alert': 'Waspada',
      'total_savings': 'Total Menabung',
      'financial_health_score': 'Skor Kesehatan Keuangan',
      'budget_leakage': 'Kebocoran Anggaran',
      'efficiency': 'Efisiensi',
      'credit_score': 'Skor Kredit',
      'smart_recommendation': 'Rekomendasi Cerdas',
      'move_to_fixed_savings': 'Pindahkan {amount} ke Tabungan Berjangka untuk bunga lebih tinggi.',
      'fixed_savings': 'Tabungan Berjangka',
      'fixed_savings_description': 'Tabungan Berjangka adalah produk simpanan berjangka waktu tertentu dengan penawaran suku bunga yang lebih tinggi daripada tabungan reguler.',
      'advantages': 'Keunggulan:',
      'advantages_list': '• Bunga tinggi hingga 5.5% per tahun.\n• Melatih disiplin rutin menabung.\n• Simpanan aman & terjamin.',
      'understood': 'Mengerti',
      'learn_more': 'Pelajari Selengkapnya',
      'edit_daily_pocket_money': 'Ubah Uang Saku Harian',
      'enter_daily_pocket': 'Masukkan nominal uang saku harian baru Anda.',
      'new_amount': 'Nominal Baru',
      'save_changes': 'SIMPAN PERUBAHAN',
      'my_debt': 'Hutang Saya',
      'receivables': 'Piutang',
      'piutang': 'Piutang',
      'usage_status': 'Status Penggunaan',
      'contact_list_title': 'Daftar Kontak (Klik Nama)',
      'detail_title': 'Detail: {name} ({type})',
      'installment_history': 'Riwayat Cicilan',
      'tips_text': 'Tips: Mengatur otomatisasi membantu Anda berhemat 15% lebih banyak setiap bulan.',
      'kategori_tabungan_title': 'Kategori Tabungan',
      'belum_ada_kategori': 'Belum ada kategori.',
      'refresh_data': 'Refresh Data',
      'kategori_kustom': 'Kategori Kustom',
      'hapus_kategori': 'Hapus Kategori?',
      'yakin_hapus_kategori': 'Apakah Anda yakin ingin menghapus "{name}"?',
      'batal': 'Batal',
      'tambah_kategori_baru': 'Tambah Kategori Baru',
      'edit_kategori': 'Edit Kategori',
      'nama_kategori': 'Nama Kategori',
      'batas_anggaran_bulanan': 'Batas Anggaran Bulanan',
      'pilih_ikon': 'Pilih Ikon',
      'pilih_warna': 'Pilih Warna',
      'simpan_kategori': 'SIMPAN KATEGORI',
      'arsip': 'Arsip',
      'anggaran_prefix': 'Anggaran: ',
      'edit': 'Edit',
      'hutang': 'Hutang',
      'nominal_bayar_cicil': 'Nominal Bayar / Cicil',
      'bayar_sekarang': 'BAYAR SEKARANG',
      'catat_hutang_baru': 'Catat Hutang Baru',
      'nama_kontak': 'Nama Kontak',
      'nominal_hutang': 'Nominal Hutang',
      'cicilan_berhasil_dicatat': 'Cicilan berhasil dicatat! ✅',
      'status_lunas': 'Status: LUNAS! 🎉',
      'daftar_pinjaman': 'Daftar Pinjaman',
      'manajemen_keuangan': 'Manajemen Keuangan',
      'detail_catatan': 'Detail Catatan',
      'sisa_label': 'Sisa: ',
      'tempo_label': 'Tempo: ',
      'aksi_cepat': 'Aksi Cepat',
      'riwayat_pembayaran': 'Riwayat Pembayaran',
      'masukkan_nominal_cicilan': 'Masukkan Nominal Cicilan',
      'tabungan_saya': 'Tabungan Saya',
      'uang_hasil_tabungan': 'Uang Hasil Tabungan',
      'tambah_saldo': 'TAMBAH SALDO',
      'tambah_saldo_tabungan': 'Tambah Saldo Tabungan',
      'nominal_top_up': 'Nominal Top Up',
      'nominal_tabungan': 'Nominal Tabungan',
      'lanjutkan_pembayaran': 'LANJUTKAN PEMBAYARAN',
      'uang_tabungan_bulanan': 'Uang Tabungan Bulanan',
      'uang_tabungan_bulanan_desc': 'Ketik manual / Pilih nominal',
      'riwayat_menabung': 'Riwayat Menabung',
      'riwayat_menabung_desc': 'Lihat detail transaksi',
      'belum_ada_riwayat_menabung': 'Belum ada riwayat menabung',
      'berhasil_menabung': 'Berhasil menabung {amount}!',
      'simpan_dan_nabung': 'SIMPAN & NABUNG',
      'berhasil_menambah_saldo': 'Berhasil menambah saldo {amount}!',
      'cari_transaksi': 'Cari transaksi...',
      'urutkan': 'Urutkan',
      'terbaru_terlebih_dulu': 'Terbaru terlebih dahulu',
      'terlama_terlebih_dulu': 'Terlama terlebih dahulu',
      'nominal_terbesar': 'Nominal terbesar',
      'nominal_terkecil': 'Nominal terkecil',
      'rata_rata': 'Rata-rata',
      'fitur_ekspor_disiapkan': 'Fitur Ekspor sedang disiapkan...',
      'tidak_ada_transaksi': 'Tidak ada transaksi ditemukan',
      'transaksi': 'Transaksi',
      'belum_ada_riwayat': 'Belum ada riwayat',
      'analisis_struktur': 'Analisis Struktur',
      'logika_pengelompokan_kategori': 'Logika pengelompokan kategori',
      'inspirasi_harian': 'INSPIRASI HARIAN',
      'kelola_kesenangan_kecil': 'Kelola kesenangan kecil Anda.',
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
      'uang_makan': 'Uang Makan',
      'uang_bensin': 'Uang Bensin',
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
      'verifikasi_biometrik': 'Verifikasi Biometrik',
      'otentikasi_berhasil': 'Sidik jari dikenali',
      'sedang_memindai': 'Sentuh terus sensor sidik jari Anda...',
      'petunjuk_pemindaian': 'Ketuk sensor sidik jari di bawah untuk mulai memverifikasi identitas Anda.',
      'otentikasi_sukses': 'Sukses! Identitas Terverifikasi',
      'memindai_sidik_jari': 'Memindai Sidik Jari...',
      'siap_memindai': 'Sentuh Untuk Memindai',
      'biometrik_berhasil_diaktifkan': 'Otentikasi biometrik berhasil diaktifkan!',
      'biometrik_dinonaktifkan': 'Otentikasi biometrik dinonaktifkan.',
    },
    'English': {
      'sisa_saldo': 'Remaining Balance',
      'sisa_uang_tabungan': 'Savings Balance',
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
      'pilih_bahasa': 'Choose Language',
      'bahasa_tersedia': 'AVAILABLE LANGUAGES',
      'bahasa_diubah_ke': 'Language changed to {language}!',
      'lainnya': 'OTHER',
      'tema_gelap_aktif': 'Dark Theme Active',
      'tema_terang_aktif': 'Light Theme Active',
      'membuka_rincian': 'Opening details: {title}',
      'nama_lengkap': 'Full Name',
      'email': 'Email',
      'nomor_telepon': 'Phone Number',
      'perangkat_terhubung': 'CONNECTED DEVICES',
      'aktif_sekarang': 'Active now',
      'terakhir_aktif_2_jam_lalu': 'Last active 2 hours ago',
      'hapus': 'Remove',
      'pengaturan_umum': 'General Settings',
      'akun_dan_keamanan': 'ACCOUNT & SECURITY',
      'informasi_pribadi': 'Personal Information',
      'nama_email_telepon': 'Name, Email, Phone',
      'kata_sandi_keamanan': 'Password & Security',
      'pin_sidik_jari': 'PIN, Fingerprint',
      'manajemen_rekening': 'Account Management',
      'rekening_terhubung': '2 Accounts Connected',
      'preferensi_aplikasi': 'APP PREFERENCES',
      'pengingat_harian_aktif': 'Daily Reminder Active',
      'pusat_bantuan': 'Help Center',
      'faq_dan_kontak_dukung': 'FAQ & Support Contact',
      'keluar_dari_akun': 'Log Out',
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
      'dana_darurat': 'Start Saving',
      'jaring_pengaman': 'Financial Safety Net',
      'dialokasikan': 'Allocated',
      'laptop_baru': 'New Laptop',
      'buku_nw': 'Books NW',
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
      'financial_audit_snackbar': 'This page evaluates your financial health based on your savings of Rp {target}.',
      'status_need_improvement': 'Needs Improvement',
      'status_very_healthy': 'Very Healthy',
      'status_healthy': 'Healthy',
      'status_alert': 'Alert',
      'total_savings': 'Total Savings',
      'financial_health_score': 'Financial Health Score',
      'budget_leakage': 'Budget Leakage',
      'efficiency': 'Efficiency',
      'credit_score': 'Credit Score',
      'smart_recommendation': 'Smart Recommendation',
      'move_to_fixed_savings': 'Move {amount} to Fixed Savings for higher interest.',
      'fixed_savings': 'Fixed Savings',
      'fixed_savings_description': 'Fixed Savings is a term deposit product with higher interest rates than regular savings.',
      'advantages': 'Advantages:',
      'advantages_list': '• High interest up to 5.5% per year.\n• Builds disciplined saving habits.\n• Secure and guaranteed savings.',
      'understood': 'Understood',
      'learn_more': 'Learn More',
      'edit_daily_pocket_money': 'Edit Daily Pocket Money',
      'enter_daily_pocket': 'Enter your new daily pocket money amount.',
      'new_amount': 'New Amount',
      'save_changes': 'SAVE CHANGES',
      'my_debt': 'My Debt',
      'receivables': 'Receivables',
      'piutang': 'Receivable',
      'usage_status': 'Usage Status',
      'contact_list_title': 'Contact List (Tap Name)',
      'detail_title': 'Detail: {name} ({type})',
      'installment_history': 'Installment History',
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
      'uang_makan': 'Food Money',
      'uang_bensin': 'Fuel Money',
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
      'verifikasi_biometrik': 'Biometric Verification',
      'otentikasi_berhasil': 'Fingerprint recognized',
      'sedang_memindai': 'Keep touching the fingerprint sensor...',
      'petunjuk_pemindaian': 'Tap the fingerprint sensor below to start verifying your identity.',
      'otentikasi_sukses': 'Success! Identity Verified',
      'memindai_sidik_jari': 'Scanning Fingerprint...',
      'siap_memindai': 'Touch to Scan',
      'biometrik_berhasil_diaktifkan': 'Biometric authentication successfully enabled!',
      'biometrik_dinonaktifkan': 'Biometric authentication disabled.',
      'kategori_tabungan_title': 'Savings Category',
      'belum_ada_kategori': 'No categories yet.',
      'refresh_data': 'Refresh Data',
      'kategori_kustom': 'Custom Category',
      'hapus_kategori': 'Delete Category?',
      'yakin_hapus_kategori': 'Are you sure you want to delete "{name}"?',
      'batal': 'Cancel',
      'tambah_kategori_baru': 'Add New Category',
      'edit_kategori': 'Edit Category',
      'nama_kategori': 'Category Name',
      'batas_anggaran_bulanan': 'Monthly Budget Limit',
      'pilih_ikon': 'Choose Icon',
      'pilih_warna': 'Choose Color',
      'simpan_kategori': 'SAVE CATEGORY',
      'arsip': 'Archive',
      'anggaran_prefix': 'Budget: ',
      'edit': 'Edit',
      'hutang': 'Debt',
      'nominal_bayar_cicil': 'Payment / Installment Amount',
      'bayar_sekarang': 'PAY NOW',
      'catat_hutang_baru': 'Record New Debt',
      'nama_kontak': 'Contact Name',
      'nominal_hutang': 'Debt Amount',
      'cicilan_berhasil_dicatat': 'Installment recorded successfully! ✅',
      'status_lunas': 'Status: PAID OFF! 🎉',
      'daftar_pinjaman': 'Loan List',
      'manajemen_keuangan': 'Financial Management',
      'detail_catatan': 'Record Details',
      'sisa_label': 'Remaining: ',
      'tempo_label': 'Due Date: ',
      'aksi_cepat': 'Quick Actions',
      'riwayat_pembayaran': 'Payment History',
      'masukkan_nominal_cicilan': 'Enter Installment Amount',
      'tabungan_saya': 'My Savings',
      'uang_hasil_tabungan': 'Savings Balance',
      'tambah_saldo': 'ADD BALANCE',
      'tambah_saldo_tabungan': 'Add Savings Balance',
      'nominal_top_up': 'Top Up Amount',
      'nominal_tabungan': 'Savings Amount',
      'lanjutkan_pembayaran': 'PROCEED TO PAYMENT',
      'uang_tabungan_bulanan': 'Monthly Savings',
      'uang_tabungan_bulanan_desc': 'Type manually / Pick an amount',
      'riwayat_menabung': 'Savings History',
      'riwayat_menabung_desc': 'View transaction details',
      'belum_ada_riwayat_menabung': 'No savings history yet',
      'berhasil_menabung': 'Saved {amount} successfully',
      'simpan_dan_nabung': 'SAVE & CONTRIBUTE',
      'berhasil_menambah_saldo': 'Successfully added balance {amount}',
      'cari_transaksi': 'Search transactions...',
      'urutkan': 'Sort by',
      'terbaru_terlebih_dulu': 'Newest first',
      'terlama_terlebih_dulu': 'Oldest first',
      'nominal_terbesar': 'Highest amount',
      'nominal_terkecil': 'Lowest amount',
      'rata_rata': 'Average',
      'fitur_ekspor_disiapkan': 'Export feature is being prepared...',
      'tidak_ada_transaksi': 'No transactions found',
      'transaksi': 'Transactions',
      'belum_ada_riwayat': 'No history yet',
      'analisis_struktur': 'Structure Analysis',
      'logika_pengelompokan_kategori': 'Category grouping logic',
      'inspirasi_harian': 'DAILY INSPIRATION',
      'kelola_kesenangan_kecil': 'Manage your small pleasures.',
    },
    '日本語': {
      'sisa_saldo': '残高',
      'sisa_uang_tabungan': '貯蓄残高',
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
      'pilih_bahasa': '言語を選択',
      'bahasa_tersedia': '使用可能な言語',
      'bahasa_diubah_ke': '{language} に言語を変更しました！',
      'lainnya': 'その他',
      'tema_gelap_aktif': 'ダークテーマが有効です',
      'tema_terang_aktif': 'ライトテーマが有効です',
      'membuka_rincian': '詳細を開いています: {title}',
      'nama_lengkap': '氏名',
      'email': 'メール',
      'nomor_telepon': '電話番号',
      'perangkat_terhubung': '接続済みデバイス',
      'aktif_sekarang': '現在アクティブ',
      'terakhir_aktif_2_jam_lalu': '2時間前に最終アクティブ',
      'hapus': '削除',
      'pengaturan_umum': '一般設定',
      'akun_dan_keamanan': 'アカウントとセキュリティ',
      'informasi_pribadi': '個人情報',
      'nama_email_telepon': '名前、メール、電話',
      'kata_sandi_keamanan': 'パスワードとセキュリティ',
      'pin_sidik_jari': 'PIN、指紋',
      'manajemen_rekening': 'アカウント管理',
      'rekening_terhubung': '接続された2つのアカウント',
      'preferensi_aplikasi': 'アプリの設定',
      'pengingat_harian_aktif': '毎日のリマインダーが有効',
      'pusat_bantuan': 'ヘルプセンター',
      'faq_dan_kontak_dukung': 'FAQとサポート連絡先',
      'keluar_dari_akun': 'ログアウト',
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
      'financial_audit_snackbar': 'このページでは、{target} の貯蓄に基づいて財務状況を評価します。',
      'status_need_improvement': '改善が必要',
      'status_very_healthy': '非常に健康',
      'status_healthy': '健康',
      'status_alert': '要注意',
      'total_savings': '総貯蓄',
      'financial_health_score': 'ファイナンシャルヘルススコア',
      'budget_leakage': '予算の漏れ',
      'efficiency': '効率',
      'credit_score': 'クレジットスコア',
      'smart_recommendation': 'スマートなおすすめ',
      'move_to_fixed_savings': '{amount} を定期預金に移してより高い利率を得ましょう。',
      'fixed_savings': '定期預金',
      'fixed_savings_description': '定期預金は、通常の貯金よりも高い金利を提供する一定期間の預金商品です。',
      'advantages': '利点:',
      'advantages_list': '• 年率最大5.5%の高金利。\n• 定期的な貯蓄習慣を身につける。\n• 安全で保証された預金。',
      'understood': '理解しました',
      'learn_more': '詳しく知る',
      'edit_daily_pocket_money': '日次お小遣いを編集',
      'enter_daily_pocket': '新しい日次お小遣いの金額を入力してください。',
      'new_amount': '新しい金額',
      'save_changes': '変更を保存',
      'my_debt': '私の負債',
      'receivables': '債権',
      'piutang': '債権',
      'usage_status': '使用状況',
      'contact_list_title': '連絡先リスト（名前をタップ）',
      'detail_title': '詳細: {name} ({type})',
      'installment_history': '分割払い履歴',
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
      'uang_makan': '食費',
      'uang_bensin': '燃料費',
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
      'verifikasi_biometrik': '生体認証',
      'otentikasi_berhasil': '指紋が照合されました',
      'sedang_memindai': '指紋センサーに触れたままにしてください...',
      'petunjuk_pemindaian': '本人確認を開始するには、下の指紋センサーをタップしてください。',
      'otentikasi_sukses': '成功！本人確認完了',
      'memindai_sidik_jari': '指紋をスキャン中...',
      'siap_memindai': 'タッチしてスキャン',
      'biometrik_berhasil_diaktifkan': '生体認証が有効になりました！',
      'biometrik_dinonaktifkan': '生体認証が無効になりました。',
      'kategori_tabungan_title': '貯金カテゴリー',
      'belum_ada_kategori': 'カテゴリーはまだありません。',
      'refresh_data': 'データを更新',
      'kategori_kustom': 'カスタムカテゴリー',
      'hapus_kategori': 'カテゴリーを削除しますか？',
      'yakin_hapus_kategori': '"{name}"を削除してもよろしいですか？',
      'batal': 'キャンセル',
      'tambah_kategori_baru': '新しいカテゴリーを追加',
      'edit_kategori': 'カテゴリーを編集',
      'nama_kategori': 'カテゴリー名',
      'batas_anggaran_bulanan': '月次予算上限',
      'pilih_ikon': 'アイコンを選択',
      'pilih_warna': '色を選択',
      'simpan_kategori': 'カテゴリーを保存',
      'arsip': 'アーカイブ',
      'anggaran_prefix': '予算: ',
      'edit': '編集',
      'hutang': '負債',
      'nominal_bayar_cicil': '返済・分割払い金額',
      'bayar_sekarang': '今すぐ支払う',
      'catat_hutang_baru': '新しい負債を記録',
      'nama_kontak': '連絡先名',
      'nominal_hutang': '負債額',
      'cicilan_berhasil_dicatat': '分割払いが記録されました！✅',
      'status_lunas': 'ステータス：完済！🎉',
      'daftar_pinjaman': 'ローンリスト',
      'manajemen_keuangan': '財務管理',
      'detail_catatan': 'レコードの詳細',
      'sisa_label': '残り: ',
      'tempo_label': '期限: ',
      'aksi_cepat': 'クイックアクション',
      'riwayat_pembayaran': '返済履歴',
      'masukkan_nominal_cicilan': '分割払い金額を入力',
      'tabungan_saya': '私の貯金',
      'uang_hasil_tabungan': '貯金残高',
      'tambah_saldo': '残高を追加',
      'tambah_saldo_tabungan': '貯金残高を追加',
      'nominal_top_up': 'トップアップ金額',
      'nominal_tabungan': '貯金金額',
      'lanjutkan_pembayaran': '支払いに進む',
      'uang_tabungan_bulanan': '月間貯金',
      'uang_tabungan_bulanan_desc': '手動入力 / 金額を選択',
      'riwayat_menabung': '貯金履歴',
      'riwayat_menabung_desc': '取引の詳細を見る',
      'belum_ada_riwayat_menabung': '貯金履歴はまだありません',
      'berhasil_menabung': '{amount} を正常に貯金しました',
      'simpan_dan_nabung': '保存して貯金',
      'berhasil_menambah_saldo': '残高 {amount} を正常に追加しました',
      'cari_transaksi': '取引を検索...',
      'urutkan': '並べ替え',
      'terbaru_terlebih_dulu': '新しい順',
      'terlama_terlebih_dulu': '古い順',
      'nominal_terbesar': '金額が大きい順',
      'nominal_terkecil': '金額が小さい順',
      'rata_rata': '平均',
      'fitur_ekspor_disiapkan': 'エクスポート機能を準備中...',
      'tidak_ada_transaksi': '取引が見つかりません',
      'transaksi': '取引',
      'belum_ada_riwayat': '履歴はまだありません',
      'analisis_struktur': '構造分析',
      'logika_pengelompokan_kategori': 'カテゴリーグループ化ロジック',
      'inspirasi_harian': '毎日のインスピレーション',
      'kelola_kesenangan_kecil': '小さな喜びを管理します。',
    },
    'العربية': {
      'sisa_saldo': 'الرصيد المتبقي',
      'sisa_uang_tabungan': 'رصيد المدخرات',
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
      'pilih_bahasa': 'اختر اللغة',
      'bahasa_tersedia': 'اللغات المتاحة',
      'bahasa_diubah_ke': 'تم تغيير اللغة إلى {language}!',
      'lainnya': 'أخرى',
      'tema_gelap_aktif': 'الوضع الداكن مفعل',
      'tema_terang_aktif': 'الوضع الفاتح مفعل',
      'membuka_rincian': 'فتح التفاصيل: {title}',
      'nama_lengkap': 'الاسم الكامل',
      'email': 'البريد الإلكتروني',
      'nomor_telepon': 'رقم الهاتف',
      'perangkat_terhubung': 'الأجهزة المتصلة',
      'aktif_sekarang': 'نشط الآن',
      'terakhir_aktif_2_jam_lalu': 'آخر نشاط قبل ساعتين',
      'hapus': 'حذف',
      'pengaturan_umum': 'الإعدادات العامة',
      'akun_dan_keamanan': 'الحساب والأمان',
      'informasi_pribadi': 'المعلومات الشخصية',
      'nama_email_telepon': 'الاسم، البريد الإلكتروني، الهاتف',
      'kata_sandi_keamanan': 'كلمة المرور والأمان',
      'pin_sidik_jari': 'PIN، بصمة الإصبع',
      'manajemen_rekening': 'إدارة الحساب',
      'rekening_terhubung': 'حسابان متصلان',
      'preferensi_aplikasi': 'تفضيلات التطبيق',
      'pengingat_harian_aktif': 'التذكير اليومي مفعل',
      'pusat_bantuan': 'مركز المساعدة',
      'faq_dan_kontak_dukung': 'الأسئلة الشائعة واتصال الدعم',
      'keluar_dari_akun': 'تسجيل الخروج',
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
      'financial_audit_snackbar': 'تقوم هذه الصفحة بتقييم صحتك المالية بناءً على مدخراتك البالغة {target}.',
      'status_need_improvement': 'يحتاج للتحسين',
      'status_very_healthy': 'صحي جدًا',
      'status_healthy': 'صحي',
      'status_alert': 'تنبيه',
      'total_savings': 'إجمالي المدخرات',
      'financial_health_score': 'درجة الصحة المالية',
      'budget_leakage': 'تسرب الميزانية',
      'efficiency': 'الكفاءة',
      'credit_score': 'درجة الائتمان',
      'smart_recommendation': 'توصية ذكية',
      'move_to_fixed_savings': 'انقل {amount} إلى المدخرات الثابتة للحصول على فائدة أعلى.',
      'fixed_savings': 'المدخرات الثابتة',
      'fixed_savings_description': 'المدخرات الثابتة هي منتج إيداع لأجل بفترة محددة يقدم أسعار فائدة أعلى من المدخرات العادية.',
      'advantages': 'المزايا:',
      'advantages_list': '• فائدة عالية تصل إلى 5.5% سنويًا.\n• يبني عادة ادخار منتظمة.\n• مدخرات آمنة ومضمونة.',
      'understood': 'فهمت',
      'learn_more': 'أعرف أكثر',
      'edit_daily_pocket_money': 'تعديل المصروف اليومي',
      'enter_daily_pocket': 'أدخل مبلغ مصروفك اليومي الجديد.',
      'new_amount': 'مبلغ جديد',
      'save_changes': 'احفظ التغييرات',
      'my_debt': 'ديوني',
      'receivables': 'المستحقات',
      'piutang': 'المستحقات',
      'usage_status': 'حالة الاستخدام',
      'contact_list_title': 'قائمة جهات الاتصال (اضغط على الاسم)',
      'detail_title': 'تفاصيل: {name} ({type})',
      'installment_history': 'سجل الأقساط',
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
      'uang_makan': 'تكاليف الطعام',
      'uang_bensin': 'تكاليف الوقود',
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
      'verifikasi_biometrik': 'التحقق البيومتري',
      'otentikasi_berhasil': 'تم التعرف على بصمة الإصبع',
      'sedang_memindai': 'استمر في لمس مستشعر البصمة...',
      'petunjuk_pemindaian': 'اضغط على مستشعر البصمة أدناه لبدء التحقق من هويتك.',
      'otentikasi_sukses': 'ناجح! تم التحقق من الهوية',
      'memindai_sidik_jari': 'جاري مسح البصمة...',
      'siap_memindai': 'المس للمسح',
      'biometrik_berhasil_diaktifkan': 'تم تفعيل المصادقة البيومترية بنجاح!',
      'biometrik_dinonaktifkan': 'تم تعطيل المصادقة البيومترية.',
      'kategori_tabungan_title': 'فئة المدخرات',
      'belum_ada_kategori': 'لا توجد فئات حتى الآن.',
      'refresh_data': 'تحديث البيانات',
      'kategori_kustom': 'فئة مخصصة',
      'hapus_kategori': 'حذف الفئة؟',
      'yakin_hapus_kategori': 'هل تريد بالتأكيد حذف "{name}"؟',
      'batal': 'إلغاء',
      'tambah_kategori_baru': 'إضافة فئة جديدة',
      'edit_kategori': 'تعديل الفئة',
      'nama_kategori': 'اسم الفئة',
      'batas_anggaran_bulanan': 'حد الميزانية الشهرية',
      'pilih_ikon': 'اختر الرمز',
      'pilih_warna': 'اختر اللون',
      'simpan_kategori': 'حفظ الفئة',
      'arsip': 'أرشيف',
      'anggaran_prefix': 'الميزانية: ',
      'edit': 'تعديل',
      'hutang': 'الديون',
      'nominal_bayar_cicil': 'مبلغ الدفع / القسط',
      'bayar_sekarang': 'ادفع الآن',
      'catat_hutang_baru': 'تسجيل دين جديد',
      'nama_kontak': 'اسم جهة الاتصال',
      'nominal_hutang': 'مبلغ الدين',
      'cicilan_berhasil_dicatat': 'تم تسجيل القسط بنجاح! ✅',
      'status_lunas': 'الحالة: تم السداد! 🎉',
      'daftar_pinjaman': 'قائمة القروض',
      'manajemen_keuangan': 'إدارة الأموال',
      'detail_catatan': 'تفاصيل السجل',
      'sisa_label': 'المتبقي: ',
      'tempo_label': 'تاريخ الاستحقاق: ',
      'aksi_cepat': 'إجراءات سريعة',
      'riwayat_pembayaran': 'سجل الدفع',
      'masukkan_nominal_cicilan': 'أدخل مبلغ القسط',
      'tabungan_saya': 'مدخراتي',
      'uang_hasil_tabungan': 'رصيد المدخرات',
      'tambah_saldo': 'إضافة الرصيد',
      'tambah_saldo_tabungan': 'إضافة رصيد المدخرات',
      'nominal_top_up': 'مبلغ الشحن',
      'nominal_tabungan': 'مبلغ المدخرات',
      'lanjutkan_pembayaran': 'متابعة الدفع',
      'uang_tabungan_bulanan': 'الادخار الشهري',
      'uang_tabungan_bulanan_desc': 'اكتب يدويًا / اختر مبلغًا',
      'riwayat_menabung': 'سجل المدخرات',
      'riwayat_menabung_desc': 'عرض تفاصيل المعاملة',
      'belum_ada_riwayat_menabung': 'لا يوجد سجل مدخرات حتى الآن',
      'berhasil_menabung': 'تم الادخار {amount} بنجاح',
      'simpan_dan_nabung': 'حفظ والمساهمة',
      'berhasil_menambah_saldo': 'تمت إضافة الرصيد {amount} بنجاح',
      'cari_transaksi': 'البحث عن معاملات...',
      'urutkan': 'الترتيب حسب',
      'terbaru_terlebih_dulu': 'الأحدث أولاً',
      'terlama_terlebih_dulu': 'الأقدم أولاً',
      'nominal_terbesar': 'أعلى مبلغ',
      'nominal_terkecil': 'أقل مبلغ',
      'rata_rata': 'المعدل',
      'fitur_ekspor_disiapkan': 'يتم تحضير ميزة التصدير...',
      'tidak_ada_transaksi': 'لم يتم العثور على معاملات',
      'transaksi': 'المعاملات',
      'kelola_kesenangan_kecil': 'أدر متعتك الصغيرة.',
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
