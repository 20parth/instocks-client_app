import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/auth/biometric_service.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/session_controller.dart';
import '../features/home/client_shell.dart';

class InstocksClientApp extends StatefulWidget {
  const InstocksClientApp({super.key});

  @override
  State<InstocksClientApp> createState() => _InstocksClientAppState();
}

class _InstocksClientAppState extends State<InstocksClientApp>
    with WidgetsBindingObserver {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    final biometric = context.read<BiometricService>();
    if (!biometric.isAppLockEnabled) {
      setState(() => _isAuthenticated = true);
      return;
    }

    final auth = await biometric.authenticate(
      reason: 'Authenticate to access Instocks',
    );
    if (mounted) {
      setState(() => _isAuthenticated = auth);
    }
  }

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
              : !_isAuthenticated
                  ? _LockedScreen(onAuthenticate: _checkAuth)
                  : session.isAuthenticated
                      ? const ClientShell()
                      : const LoginScreen(),
        );
      },
    );
  }
}

class _LockedScreen extends StatelessWidget {
  final VoidCallback onAuthenticate;

  const _LockedScreen({required this.onAuthenticate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'App Locked',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Authenticate to access Instocks',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onAuthenticate,
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Unlock'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
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
