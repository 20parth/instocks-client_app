import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/auth/biometric_service.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isChecking = true;
  bool _biometricAvailable = false;
  String _biometricLabel = 'Biometric';
  IconData _biometricIcon = Icons.fingerprint_rounded;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _checkBiometrics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    final biometric = context.read<BiometricService>();
    final canAuth = await biometric.canAuthenticate();
    final types = await biometric.getAvailableBiometrics();

    if (mounted) {
      setState(() {
        _biometricAvailable = canAuth;
        _isChecking = false;

        if (types.contains(BiometricType.face)) {
          _biometricLabel = 'Face ID';
          _biometricIcon = Icons.face_rounded;
        } else if (types.contains(BiometricType.fingerprint)) {
          _biometricLabel = 'Fingerprint';
          _biometricIcon = Icons.fingerprint_rounded;
        } else if (types.contains(BiometricType.iris)) {
          _biometricLabel = 'Iris';
          _biometricIcon = Icons.remove_red_eye_rounded;
        } else if (types.contains(BiometricType.strong)) {
          _biometricLabel = 'PIN/Pattern/Password';
          _biometricIcon = Icons.pin_rounded;
        } else {
          _biometricLabel = 'Device Security';
          _biometricIcon = Icons.security_rounded;
        }
      });

      _animationController.forward();
    }
  }

  Future<void> _enableBiometric() async {
    final biometric = context.read<BiometricService>();

    final auth = await biometric.authenticate(
      reason: 'Set up app lock to secure your account',
    );

    if (auth && mounted) {
      await biometric.setAppLockEnabled(true);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  void _skipSetup() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Checking device security...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_biometricAvailable) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Security Setup'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security_rounded,
                  size: 80,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Biometric Not Available',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your device doesn\'t support biometric authentication. '
                  'Please set up a PIN, pattern, or password in your device settings first.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _skipSetup,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('Continue Without Lock'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient background
            Positioned.fill(
              child: Container(
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
              ),
            ),
            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _skipSetup,
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Animated icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 140,
                        height: 140,
                        margin: const EdgeInsets.only(bottom: 32),
                        alignment: Alignment.center,
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
                        child: Icon(
                          _biometricIcon,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Secure Your Account',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Enable $_biometricLabel to protect your portfolio data',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(179),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Features list
                  ..._buildFeatureList(theme),
                  const SizedBox(height: 48),
                  // Enable button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: FilledButton.icon(
                      onPressed: _enableBiometric,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: Icon(_biometricIcon, size: 28),
                      label: Text(
                        'Enable $_biometricLabel',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: OutlinedButton(
                      onPressed: _skipSetup,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('I\'ll Do This Later'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList(ThemeData theme) {
    final features = [
      {
        'icon': Icons.lock_outline_rounded,
        'title': 'Instant Access',
        'subtitle': 'Unlock the app quickly with $_biometricLabel',
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'Enhanced Security',
        'subtitle': 'Keep your portfolio data safe from unauthorized access',
      },
      {
        'icon': Icons.privacy_tip_outlined,
        'title': 'Privacy First',
        'subtitle': 'Your biometric data never leaves your device',
      },
    ];

    return features
        .map(
          (feature) => FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['subtitle'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}
