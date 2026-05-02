import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/theme_data/ThemeDataLight.dart';
import 'package:securemail/core/theme/theme_data/ThemeDataDark.dart';
import 'package:securemail/core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SecureMail(),
    ),
  );
}

class SecureMail extends ConsumerWidget {
  const SecureMail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SecureMail',
      theme: getThemeLight(),
      darkTheme: getThemeDark(),
      themeMode: themeState.themeMode,
      routerConfig: appRouter,
    );
  }
}
