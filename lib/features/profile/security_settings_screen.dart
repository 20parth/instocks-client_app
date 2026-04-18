import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/auth/biometric_service.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricAvailable = false;
  String _biometricLabel = 'Biometric';
  IconData _biometricIcon = Icons.fingerprint_rounded;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final biometric = context.read<BiometricService>();
    final canAuth = await biometric.canAuthenticate();
    final types = await biometric.getAvailableBiometrics();
    if (mounted) {
      setState(() {
        _biometricAvailable = canAuth;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometric = context.watch<BiometricService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // App Lock Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF162944),
                        const Color(0xFF0E1727),
                      ]
                    : [
                        const Color(0xFFE0F2FE),
                        const Color(0xFFBAE6FD),
                      ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        _biometricIcon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Lock',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            biometric.isAppLockEnabled
                                ? 'Enabled'
                                : 'Tap to enable',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Toggle Card
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    _biometricIcon,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    _biometricLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    biometric.isAppLockEnabled
                        ? 'Authentication required on app launch'
                        : 'Secure your app with $_biometricLabel',
                  ),
                  value: biometric.isAppLockEnabled,
                  onChanged: (value) async {
                    if (value) {
                      final auth = await biometric.authenticate(
                        reason: 'Verify to enable app lock',
                      );
                      if (auth) {
                        await biometric.setAppLockEnabled(true);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'App lock enabled with $_biometricLabel'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    } else {
                      await biometric.setAppLockEnabled(false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('App lock disabled'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          // Information Section
          if (!biometric.isAppLockEnabled && _biometricAvailable) ...[
            const SizedBox(height: 32),
            Text(
              'Why Enable App Lock?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              theme,
              Icons.speed_rounded,
              'Quick Access',
              'Unlock instantly with $_biometricLabel - faster than typing a password',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              theme,
              Icons.shield_outlined,
              'Enhanced Security',
              'Protect sensitive portfolio and financial data from unauthorized access',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              theme,
              Icons.privacy_tip_outlined,
              'Privacy Guaranteed',
              'Your biometric data stays on your device and never leaves it',
            ),
          ],
          if (biometric.isAppLockEnabled) ...[
            const SizedBox(height: 32),
            Text(
              'Manage App Lock',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: theme.colorScheme.errorContainer.withOpacity(0.5),
              child: ListTile(
                leading: Icon(
                  Icons.lock_open_rounded,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Disable App Lock',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Remove authentication requirement',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer.withAlpha(179),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Disable App Lock?'),
                      content: const Text(
                        'You will no longer need to authenticate to open the app. '
                        'Your portfolio data will be accessible to anyone with access to your device.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                          ),
                          child: const Text('Disable'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    await biometric.setAppLockEnabled(false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('App lock has been disabled'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    ThemeData theme,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
