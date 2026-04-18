import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/auth/biometric_service.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/session_controller.dart';
import '../features/auth/biometric_setup_screen.dart';
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
        Widget home;

        if (session.isBootstrapping) {
          home = const _SplashScreen();
        } else if (!_isAuthenticated) {
          home = _LockedScreen(onAuthenticate: _checkAuth);
        } else if (!session.isAuthenticated) {
          home = const LoginScreen();
        } else if (session.shouldPromptBiometricSetup) {
          home = _BiometricSetupWrapper(
            onComplete: () {
              session.dismissBiometricSetup();
            },
          );
        } else {
          home = const ClientShell();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Instocks Client',
          theme: AppTheme.buildLight(),
          darkTheme: AppTheme.buildDark(),
          themeMode: ThemeMode.system,
          home: home,
        );
      },
    );
  }
}

class _BiometricSetupWrapper extends StatelessWidget {
  final VoidCallback onComplete;

  const _BiometricSetupWrapper({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return BiometricSetupScreen();
  }
}

class _LockedScreen extends StatelessWidget {
  final VoidCallback onAuthenticate;

  const _LockedScreen({required this.onAuthenticate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF09111F),
                    const Color(0xFF0E1727),
                    const Color(0xFF162944),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                    const Color(0xFFCBD5E1),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Animated lock icon with glow
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Instocks Locked',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Authenticate to access your portfolio',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: onAuthenticate,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.fingerprint_rounded, size: 28),
                  label: const Text(
                    'Unlock App',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // Security message
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withAlpha(102),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Protected by device security',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(102),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
