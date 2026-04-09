import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/theme/theme_data/ThemeDataLight.dart';
import 'package:securemail/core/theme/theme_data/ThemeDataDark.dart';
import 'package:securemail/features/auth/screens/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(  
      child: SecureMail(),
    ),
  );
}

class SecureMail extends StatelessWidget {
  const SecureMail({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SecureMail',
      theme:      getThemeLight(),
      darkTheme:  getThemeDark(),
      themeMode:  ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}