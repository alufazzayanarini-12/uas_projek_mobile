import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Import the generated localizations from the package's l10n folder
import 'package:uasnw_projek/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/account_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/category_provider.dart';
import 'providers/transaction_provider.dart';
import 'theme/app_theme.dart';
import 'screens/pin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  final categoryProvider = CategoryProvider();
  await categoryProvider.loadCategories(); 

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
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: settings.isAppLockEnabled ? const PinScreen() : const MainNavigationScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
