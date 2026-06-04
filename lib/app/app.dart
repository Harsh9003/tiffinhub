import 'package:flutter/material.dart';

import '../features/auth/pages/auth_wrapper.dart';
import 'theme.dart';

class TiffinHubApp extends StatelessWidget {
  const TiffinHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TiffinHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}