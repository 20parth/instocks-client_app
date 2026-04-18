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
  List<BiometricType> _biometricTypes = [];
  String _biometricLabel = 'Biometrics';

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
        _biometricTypes = types;
        if (types.contains(BiometricType.face)) {
          _biometricLabel = 'Face ID';
        } else if (types.contains(BiometricType.fingerprint)) {
          _biometricLabel = 'Fingerprint';
        } else if (types.contains(BiometricType.iris)) {
          _biometricLabel = 'Iris';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometric = context.watch<BiometricService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'App Lock',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                _biometricTypes.contains(BiometricType.face)
                    ? Icons.face_rounded
                    : Icons.fingerprint_rounded,
              ),
              title: Text(_biometricLabel),
              subtitle: Text(
                biometric.isAppLockEnabled
                    ? 'App requires authentication on open'
                    : 'Disabled - tap to enable',
              ),
              value: biometric.isAppLockEnabled,
              onChanged: (value) async {
                if (value) {
                  final auth = await biometric.authenticate(
                    reason: 'Verify to enable app lock',
                  );
                  if (auth) {
                    await biometric.setAppLockEnabled(true);
                  }
                } else {
                  await biometric.setAppLockEnabled(false);
                }
                setState(() {});
              },
            ),
          ),
          if (!biometric.isAppLockEnabled && _biometricAvailable) ...[
            const SizedBox(height: 24),
            Text(
              'How it works',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable app lock to require $_biometricLabel authentication every time you open the app or return from background. '
              'This uses your device\'s built-in security - no separate setup needed.',
            ),
          ],
          if (biometric.isAppLockEnabled) ...[
            const SizedBox(height: 24),
            Card(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(
                  Icons.lock_outline_rounded,
                  color: theme.colorScheme.onErrorContainer,
                ),
                title: Text(
                  'Disable App Lock',
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
                subtitle: Text(
                  'Remove authentication requirement',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer.withAlpha(179),
                  ),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Disable App Lock?'),
                      content: const Text(
                        'You will no longer need to authenticate to open the app.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Disable'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    await biometric.setAppLockEnabled(false);
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
}
