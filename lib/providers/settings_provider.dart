import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isBalanceHidden = false;
  bool _isPinEnabled = false;
  bool _isBiometricEnabled = false;

  bool get isBalanceHidden => _isBalanceHidden;
  bool get isPinEnabled => _isPinEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isBalanceHidden = prefs.getBool('hide_balance') ?? false;
    _isPinEnabled = prefs.getString('app_pin') != null;
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleBalanceVisibility() async {
    _isBalanceHidden = !_isBalanceHidden;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hide_balance', _isBalanceHidden);
    notifyListeners();
  }

  Future<void> setPinEnabled(bool value) async {
    _isPinEnabled = value;
    notifyListeners();
  }

  Future<void> toggleBiometric(bool value) async {
    _isBiometricEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', _isBiometricEnabled);
    notifyListeners();
  }
}
