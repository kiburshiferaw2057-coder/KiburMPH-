import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class BingoApiService {
  final http.Client _client;

  BingoApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> loginV3({
    required String identifier,
    required String credential,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/user/login/v3');
    final resp = await _client
        .post(
          uri,
          headers: _jsonHeaders,
          body: jsonEncode({
            'identifier': identifier.trim(),
            'credential': credential,
          }),
        )
        .timeout(const Duration(seconds: 20));
    return _decodeResponse(resp);
  }

  Future<Map<String, dynamic>> fetchActiveBanner() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/banner/active');
    final resp = await _client
        .get(uri, headers: _jsonHeaders)
        .timeout(const Duration(seconds: 15));
    return _decodeResponse(resp);
  }

  Future<Map<String, dynamic>> fetchWithdrawMethods() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/withdraw-method/available');
    final resp = await _client
        .get(uri, headers: _jsonHeaders)
        .timeout(const Duration(seconds: 15));
    return _decodeResponse(resp);
  }

  Future<Map<String, dynamic>> submitWithdrawV2({
    required String bearerToken,
    required String method,
    required String accountNumber,
    required double amountBirr,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/transaction/withdraw/v2');
    final resp = await _client
        .post(
          uri,
          headers: {
            ..._jsonHeaders,
            'Authorization': 'Bearer $bearerToken',
          },
          body: jsonEncode({
            'method': method,
            'accountNumber': accountNumber.trim(),
            'accountHolder': AppConfig.accountHolder,
            'amount': amountBirr,
            'currency': 'ETB',
          }),
        )
        .timeout(const Duration(seconds: 20));
    return _decodeResponse(resp);
  }

  Map<String, dynamic> _decodeResponse(http.Response resp) {
    final bodyText = resp.body.trim();
    Map<String, dynamic> decoded = {};
    if (bodyText.isNotEmpty) {
      try {
        final raw = jsonDecode(bodyText);
        if (raw is Map<String, dynamic>) {
          decoded = raw;
        } else {
          decoded = {'data': raw};
        }
      } catch (_) {
        decoded = {'raw': bodyText};
      }
    }
    return {
      'statusCode': resp.statusCode,
      'ok': resp.statusCode >= 200 && resp.statusCode < 300,
      ...decoded,
    };
  }
}
