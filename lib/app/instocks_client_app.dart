import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/session_controller.dart';
import '../features/home/client_shell.dart';

class InstocksClientApp extends StatelessWidget {
  const InstocksClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionController>(
      builder: (context, session, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Instocks Client',
          theme: AppTheme.buildLight(),
          darkTheme: AppTheme.buildDark(),
          themeMode: ThemeMode.system,
          home: session.isBootstrapping
              ? const _SplashScreen()
              : session.isAuthenticated
                  ? const ClientShell()
                  : const LoginScreen(),
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
