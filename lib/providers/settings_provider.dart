import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isBalanceHidden = false;
  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  String _userName = 'Arini'; // Nama Default

  bool get isBalanceHidden => _isBalanceHidden;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  String get userName => _userName;
  
  bool get isPinEnabled => _isAppLockEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isBalanceHidden = prefs.getBool('hide_balance') ?? false;
    _isAppLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _userName = prefs.getString('user_name') ?? 'Arini';
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
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
}
