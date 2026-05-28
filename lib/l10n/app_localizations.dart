import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @sisa_saldo.
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance'**
  String get sisa_saldo;

  /// No description provided for @pemasukan.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get pemasukan;

  /// No description provided for @pengeluaran.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get pengeluaran;

  /// No description provided for @tabungan.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get tabungan;

  /// No description provided for @riwayat.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get riwayat;

  /// No description provided for @tambah_transaksi.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get tambah_transaksi;

  /// No description provided for @nominal.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get nominal;

  /// No description provided for @simpan.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get simpan;

  /// No description provided for @preferensi.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferensi;

  /// No description provided for @dukungan.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get dukungan;

  /// No description provided for @bahasa.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get bahasa;

  /// No description provided for @mata_uang.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get mata_uang;

  /// No description provided for @pengaturan.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get pengaturan;

  /// No description provided for @profil.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profil;

  /// No description provided for @anggota_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium Member'**
  String get anggota_premium;

  /// No description provided for @tentang_aplikasi.
  ///
  /// In en, this message translates to:
  /// **'About Application'**
  String get tentang_aplikasi;

  /// No description provided for @kebijakan_privasi.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get kebijakan_privasi;

  /// No description provided for @notifikasi.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifikasi;

  /// No description provided for @mode_gelap.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get mode_gelap;

  /// No description provided for @uang_saku.
  ///
  /// In en, this message translates to:
  /// **'My Pocket Money'**
  String get uang_saku;

  /// No description provided for @dompet.
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet'**
  String get dompet;

  /// No description provided for @kesehatan_keuangan.
  ///
  /// In en, this message translates to:
  /// **'Financial Health'**
  String get kesehatan_keuangan;

  /// No description provided for @rencana_keuangan.
  ///
  /// In en, this message translates to:
  /// **'Financial Plan'**
  String get rencana_keuangan;

  /// No description provided for @pilih_kategori.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get pilih_kategori;

  /// No description provided for @keterangan.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get keterangan;

  /// No description provided for @tanggal.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tanggal;

  /// No description provided for @akun_asal.
  ///
  /// In en, this message translates to:
  /// **'Source Account'**
  String get akun_asal;

  /// No description provided for @selesai.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get selesai;

  /// No description provided for @atur_limit.
  ///
  /// In en, this message translates to:
  /// **'Set Limit'**
  String get atur_limit;

  /// No description provided for @target_anda.
  ///
  /// In en, this message translates to:
  /// **'Your Goals'**
  String get target_anda;

  /// No description provided for @dana_darurat.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get dana_darurat;

  /// No description provided for @jaring_pengaman.
  ///
  /// In en, this message translates to:
  /// **'Financial Safety Net'**
  String get jaring_pengaman;

  /// No description provided for @dialokasikan.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get dialokasikan;

  /// No description provided for @laptop_baru.
  ///
  /// In en, this message translates to:
  /// **'New Laptop'**
  String get laptop_baru;

  /// No description provided for @buku_nw.
  ///
  /// In en, this message translates to:
  /// **'Books NW'**
  String get buku_nw;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @hapus.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get hapus;

  /// No description provided for @target_label.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target_label;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
