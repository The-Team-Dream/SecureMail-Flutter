import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/theme_data/ThemeDataLight.dart';
import 'package:securemail/core/theme/theme_data/ThemeDataDark.dart';
import 'package:securemail/core/theme/theme_controller.dart';

import 'package:securemail/features/auth/providers/auth_provider.dart';

import 'package:securemail/core/utils/url_strategy_helper.dart'
    if (dart.library.html) 'package:securemail/core/utils/url_strategy_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathStrategy();
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
    final router = ref.watch(routerProvider);
    // Watch accessToken: null when logged out, unique per session when logged in.
    // ValueKey forces MaterialApp (and its entire widget tree) to rebuild on user change.
    final token = ref.watch(authProvider.select((s) => s.accessToken));

    return MaterialApp.router(
      key: ValueKey(token),
      debugShowCheckedModeBanner: false,
      title: 'SecureMail',
      theme: getThemeLight(),
      darkTheme: getThemeDark(),
      themeMode: themeState.themeMode,
      routerConfig: router,
    );
  }
}
