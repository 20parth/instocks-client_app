import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/instocks_client_app.dart';
import 'core/network/api_client.dart';
import 'core/storage/session_storage.dart';
import 'features/auth/session_controller.dart';
import 'features/client/client_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SessionStorage();
  final apiClient = ApiClient(storage: storage);
  final clientApi = ClientApi(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<SessionStorage>.value(value: storage),
        Provider<ApiClient>.value(value: apiClient),
        Provider<ClientApi>.value(value: clientApi),
        ChangeNotifierProvider<SessionController>(
          create: (_) => SessionController(clientApi, storage)..bootstrap(),
        ),
      ],
      child: const InstocksClientApp(),
    ),
  );
}
