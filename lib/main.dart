import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/instocks_client_app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/session_storage.dart';
import 'core/auth/biometric_service.dart';
import 'features/auth/session_controller.dart';
import 'features/client/client_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();

  final prefs = await SharedPreferences.getInstance();
  final storage = SessionStorage();
  final apiClient = ApiClient(storage: storage);
  final clientApi = ClientApi(apiClient);
  final biometricService = BiometricService(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<SessionStorage>.value(value: storage),
        Provider<ApiClient>.value(value: apiClient),
        Provider<ClientApi>.value(value: clientApi),
        Provider<BiometricService>.value(value: biometricService),
        ChangeNotifierProvider<SessionController>(
          create: (_) => SessionController(clientApi, storage)..bootstrap(),
        ),
      ],
      child: const InstocksClientApp(),
    ),
  );
}
