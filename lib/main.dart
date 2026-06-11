import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'database/db_helper.dart';
import 'providers/account_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/category_provider.dart';
import 'providers/transaction_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  final categoryProvider = CategoryProvider();
  await categoryProvider.loadCategories(); 

  // Reset/migration to set initial balance and saving figures to 0
  final prefs = await SharedPreferences.getInstance();
  final hasReset = prefs.getBool('has_reset_balances_v5') ?? false;
  if (!hasReset) {
    await prefs.setDouble('savings_current', 0.0);
    await prefs.setDouble('emergency_current', 0.0);
    await prefs.setString('savings_history', json.encode([]));
    
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update('accounts', {'balance': 0.0});
      await db.delete('transactions');
    } catch (e) {
      print("Error resetting database: $e");
    }
    
    await prefs.setBool('has_reset_balances_v5', true);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: categoryProvider),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: settings.translate('tabunganku'),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme, 
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: settings.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('id'),
            Locale('ja'),
            Locale('ar'),
          ],
          home: const MainNavigationScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
