import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SettingsProvider with ChangeNotifier {
  bool _isBalanceHidden = false;
  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isDarkMode = false;
  String _userName = 'Arini'; 
  String? _profileImagePath;
  double _dailyPocketMoney = 50000.0; // Uang saku harian default
  double _foodLimit = 500000.0; // Limit Makan dan Minum
  double _transportLimit = 150000.0; // Limit Transportasi & Pengiriman

  bool get isBalanceHidden => _isBalanceHidden;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;
  double get dailyPocketMoney => _dailyPocketMoney;
  double get foodLimit => _foodLimit;
  double get transportLimit => _transportLimit;
  
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

  ImageProvider getProfileImageProvider() {
    if (_profileImagePath != null && File(_profileImagePath!).existsSync()) {
      return FileImage(File(_profileImagePath!));
    }
    return const AssetImage('assets/profile_arini.jpg');
  }
}
