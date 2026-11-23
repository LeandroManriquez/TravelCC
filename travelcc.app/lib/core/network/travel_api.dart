import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class TravelApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  TravelApiException(this.message, {this.errorCode, this.statusCode});

  @override
  String toString() => message;
}

class TravelApi {
  static Future< Map< String, dynamic > > get(String path) =>
      _request('GET', path);

  static Future< Map< String, dynamic > > post(
    String path, [
    Map<String, dynamic>? body,
  ]) =>
      _request('POST', path, body: body);

  static Future< Map< String, dynamic > > patch(
    String path,
    Map<String, dynamic> body,
  ) =>
      _request('PATCH', path, body: body);

  static Future< Map< String, dynamic > > put(
    String path,
    Map<String, dynamic> body,
  ) =>
      _request('PUT', path, body: body);

  static Future< Map< String, dynamic > > delete(String path) =>
      _request('DELETE', path);

  static Future< Map< String, dynamic > > _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw TravelApiException(
        'Sesión expirada. Vuelve a iniciar sesión.',
        statusCode: 401,
      );
    }

    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$normalizedPath');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final request = await client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 12));
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      final rawText = await response.transform(utf8.decoder).join();

      Map<String, dynamic> decoded = {};
      if (rawText.trim().isNotEmpty) {
        final parsed = jsonDecode(rawText);
        if (parsed is Map<String, dynamic>) {
          decoded = parsed;
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }

      final msg = decoded['message']?.toString() ??
          'Error del servidor (${response.statusCode})';
      final code = decoded['error_code']?.toString();
      throw TravelApiException(
        msg,
        errorCode: code,
        statusCode: response.statusCode,
      );
    } on TravelApiException {
      rethrow;
    } on SocketException {
      throw TravelApiException(
        'No se pudo conectar con el servidor backend.',
        errorCode: 'ERR_NETWORK',
      );
    } on TimeoutException {
      throw TravelApiException(
        'El servidor tardó demasiado en responder.',
        errorCode: 'ERR_TIMEOUT',
      );
    } catch (e) {
      throw TravelApiException('Error inesperado: $e');
    } finally {
      client.close();
    }
  }
}