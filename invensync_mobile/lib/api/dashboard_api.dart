import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/dashboard.dart';

class DashboardApi {
  final ApiClient _client;

  DashboardApi(this._client);

  Future<DashboardStats> getStats() async {
    final response = await _client.get('/dashboard/stats');
    return DashboardStats.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getSalesChart({
    required String period,
    int? lastN,
  }) async {
    final queryParams = <String, dynamic>{'period': period};
    if (lastN != null) queryParams['lastN'] = lastN;

    final response = await _client.get(
      '/dashboard/sales-chart',
      queryParameters: queryParams,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 10}) async {
    final response = await _client.get(
      '/dashboard/recent-activity',
      queryParameters: {'limit': limit},
    );
    return (response.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}