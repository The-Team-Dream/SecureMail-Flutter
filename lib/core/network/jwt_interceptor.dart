import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:securemail/core/constants/AppConstants.dart';

class JwtInterceptor extends Interceptor {
  JwtInterceptor(this._dio, {this.onLogout});

  final Dio _dio;

  /// Callback بيتشال لما الـ session تنتهي (401)
  /// اربطه من ApiClient.setLogoutCallback()
  final Future<void> Function()? onLogout;

  final _storage = const FlutterSecureStorage();

  // ── 1. أضف الـ Token لكل request ────────────────────────
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.secureAccessToken);

    if (token != null) {
      debugPrint('[JwtInterceptor] Token found, adding to headers');
      options.headers[ApiConstants.headerAuthorization] =
          '${ApiConstants.bearerPrefix}$token';
    } else {
      debugPrint('[JwtInterceptor] No token found in storage for ${options.path}');
    }

    handler.next(options);
  }

  // ── 2. لو 401 → امسح الـ storage وعمل logout ────────────
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _logout();
    }
    handler.next(err);
  }

  // ── Logout ───────────────────────────────────────────────
  Future<void> _logout() async {
    await _storage.deleteAll();
    debugPrint('[JwtInterceptor] Session expired → logging out');
    await onLogout?.call();
  }
}