import 'package:flutter/material.dart';

import 'core/theme/fingo_theme.dart';
import 'features/auth/screens/login_page.dart';
import 'features/auth/screens/register_page.dart';
import 'features/budgets/screens/budgets_page.dart';
import 'features/navigation/screens/main_navigation_page.dart';
import 'features/movements/screens/home_page.dart';
import 'core/api/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.loadToken();
  runApp(const FingoApp());
}

class FingoApp extends StatelessWidget {
  const FingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FINGO',
      debugShowCheckedModeBanner: false,
      theme: FingoTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/app': (_) => const MainNavigationPage(),
        '/budgets': (_) => const BudgetsPage(),
        '/movements': (_) => const HomePage(),
      },
    );
  }
}
