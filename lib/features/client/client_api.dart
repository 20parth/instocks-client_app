import '../../core/models/auth_user.dart';
import '../../core/models/client_notification_item.dart';
import '../../core/models/client_profile.dart';
import '../../core/models/fund_entry_item.dart';
import '../../core/models/notification_preference.dart';
import '../../core/models/portfolio_item.dart';
import '../../core/models/roi_entry.dart';
import '../../core/network/api_client.dart';

class ClientApi {
  ClientApi(this._client);

  final ApiClient _client;

  Map<String, dynamic> _data(dynamic response) {
    final body = response.data as Map<String, dynamic>;
    return (body['data'] ?? <String, dynamic>{}) as Map<String, dynamic>;
  }

  List<dynamic> _collection(dynamic response) {
    final body = response.data as Map<String, dynamic>;
    return (body['data'] as List<dynamic>? ?? <dynamic>[]);
  }

  Future<Map<String, dynamic>> login({required String login, required String password}) async {
    final response = await _client.post('/auth/login', data: {
      'login': login,
      'password': password,
    });

    final body = response.data as Map<String, dynamic>;
    final data = (body['data'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    final user = AuthUser.fromJson((data['user'] ?? <String, dynamic>{}) as Map<String, dynamic>);

    return {
      'token': data['token'] as String? ?? '',
      'user': user,
    };
  }

  Future<AuthUser> me() async {
    final response = await _client.get('/auth/me');
    final user = _data(response)['user'] as Map<String, dynamic>;
    return AuthUser.fromJson(user);
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  Future<Map<String, dynamic>> getClientSummary() async {
    final response = await _client.get('/client/reports/summary');
    return _data(response);
  }

  Future<List<PortfolioItem>> getPortfolios() async {
    final response = await _client.get('/client/portfolios');
    return _collection(response)
        .map((item) => PortfolioItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PortfolioItem> getPortfolio(int id) async {
    final response = await _client.get('/client/portfolios/$id');
    return PortfolioItem.fromJson(_data(response));
  }

  Future<Map<String, dynamic>> getPortfolioStatement(int portfolioId, {String? dateFrom, String? dateTo}) async {
    final response = await _client.get(
      '/client/reports/portfolio/$portfolioId',
      query: {
        if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
        if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
      },
    );

    return _data(response);
  }

  Future<List<RoiEntry>> getPortfolioRoi(int portfolioId) async {
    final response = await _client.get('/client/roi/portfolio/$portfolioId');
    final data = _data(response);
    final entries = data['entries'] as List<dynamic>? ?? <dynamic>[];
    return entries
        .map((item) => RoiEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FundEntryItem>> getFundEntries({int? portfolioId, String? status}) async {
    final response = await _client.get(
      '/client/funds/entries',
      query: {
        if (portfolioId != null) 'portfolio_id': portfolioId,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    return _collection(response)
        .map((item) => FundEntryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ClientNotificationItem>> getNotifications() async {
    final response = await _client.get('/client/notifications');
    return _collection(response)
        .map((item) => ClientNotificationItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationRead(int notificationId) async {
    await _client.patch('/client/notifications/$notificationId/read');
  }

  Future<List<NotificationPreference>> getNotificationPreferences() async {
    final response = await _client.get('/client/notification-preferences');
    return _collection(response)
        .map((item) => NotificationPreference.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<NotificationPreference>> updateNotificationPreferences(List<NotificationPreference> preferences) async {
    final response = await _client.patch(
      '/client/notification-preferences',
      data: {
        'preferences': preferences.map((item) => item.toPayload()).toList(),
      },
    );

    return _collection(response)
        .map((item) => NotificationPreference.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ClientProfile> getProfile() async {
    final response = await _client.get('/client/profile');
    return ClientProfile.fromJson(_data(response));
  }

  Future<ClientProfile> updateProfile(Map<String, dynamic> payload) async {
    final response = await _client.patch('/client/profile', data: payload);
    return ClientProfile.fromJson(_data(response));
  }
}
