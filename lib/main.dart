import 'package:flutter/material.dart';

import 'core/theme/fingo_theme.dart';
import 'features/movements/screens/home_page.dart';

void main() {
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
      home: const HomePage(),
    );
  }
}
