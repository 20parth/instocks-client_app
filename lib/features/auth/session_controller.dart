import 'package:flutter/foundation.dart';

import '../../core/models/auth_user.dart';
import '../../core/storage/session_storage.dart';
import '../client/client_api.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._api, this._storage);

  final ClientApi _api;
  final SessionStorage _storage;

  bool _isBootstrapping = true;
  bool _isSubmitting = false;
  String? _token;
  AuthUser? _user;

  bool get isBootstrapping => _isBootstrapping;
  bool get isSubmitting => _isSubmitting;
  bool get isAuthenticated => _token != null && _user != null;
  AuthUser? get user => _user;

  Future<void> bootstrap() async {
    _token = await _storage.readToken();
    final storedUser = await _storage.readUser();

    if (_token == null || storedUser == null) {
      _isBootstrapping = false;
      notifyListeners();
      return;
    }

    _user = AuthUser.fromJson(storedUser);

    try {
      _user = await _api.me();
      await _storage.saveUser(_user!.toJson());
    } catch (_) {
      await _storage.clear();
      _token = null;
      _user = null;
    }

    _isBootstrapping = false;
    notifyListeners();
  }

  Future<void> login({required String login, required String password}) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await _api.login(login: login, password: password);
      final user = result['user'] as AuthUser;
      final token = result['token'] as String;

      if (!user.isClient) {
        throw Exception('This app is only available for client accounts.');
      }

      _token = token;
      _user = user;
      await _storage.saveToken(token);
      await _storage.saveUser(user.toJson());
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
    }

    _token = null;
    _user = null;
    await _storage.clear();
    notifyListeners();
  }
}
