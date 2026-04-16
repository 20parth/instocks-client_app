import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/models/client_profile.dart';
import '../../shared/widgets/app_card.dart';
import '../auth/session_controller.dart';
import '../client/client_api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ClientProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ClientApi>().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();

    return SafeArea(
      child: FutureBuilder<ClientProfile>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Profile',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                  'Client identity, linked profile details, and contact information.'),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(profile.email),
                    Text('Client Code: ${profile.clientCode}'),
                    Text('Phone: ${profile.phone ?? '—'}'),
                    Text('KYC: ${profile.kycStatus ?? 'Pending'}'),
                    Text('DOB: ${AppFormatters.date(profile.dateOfBirth)}'),
                    Text('PAN: ${profile.panNumber ?? '—'}'),
                    Text('Nominee: ${profile.nomineeName ?? '—'}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => session.logout(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }
}
