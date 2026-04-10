import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:securemail/core/constants/AppConstants.dart';
import 'package:securemail/core/errors/app_exceptions.dart';

class JwtInterceptor extends Interceptor {
  JwtInterceptor(this._dio);

  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  // ── 1. On Request → أضف الـ Token ──────────────────────────
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.secureAccessToken);

    if (token != null) {
      options.headers[ApiConstants.headerAuthorization] =
          '${ApiConstants.bearerPrefix}$token';
    }

    handler.next(options);
  }

  // ── 2. On Error → لو 401 اعمل Refresh ─────────────────────
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // لو الـ request ده هو refresh نفسه → logout مباشرة
    if (err.requestOptions.path == ApiConstants.refreshToken) {
      await _logout();
      handler.reject(err);
      return;
    }

    // لو في refresh جاري → حط الـ request في القايمة
    if (_isRefreshing) {
      _pendingRequests.add(_PendingRequest(err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final newToken = await _refreshAccessToken();

      if (newToken == null) {
        await _logout();
        handler.reject(err);
        _rejectPending(err);
        return;
      }

      // حفظ الـ token الجديد
      await _storage.write(
        key:   AppConstants.secureAccessToken,
        value: newToken,
      );

      // إعادة الـ request الأصلي
      final response = await _retry(err.requestOptions, newToken);
      handler.resolve(response);

      // إعادة كل الـ requests المتأخرة
      await _resolvePending(newToken);
    } catch (_) {
      await _logout();
      handler.reject(err);
      _rejectPending(err);
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  // ── Private Helpers ─────────────────────────────────────

  Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = await _storage.read(
        key: AppConstants.secureRefreshToken,
      );

      if (refreshToken == null) return null;

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      return response.data['access_token'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<Response> _retry(RequestOptions options, String token) {
    return _dio.request(
      options.path,
      data:            options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method:  options.method,
        headers: {
          ...options.headers,
          ApiConstants.headerAuthorization: '${ApiConstants.bearerPrefix}$token',
        },
      ),
    );
  }

  Future<void> _resolvePending(String newToken) async {
    for (final pending in _pendingRequests) {
      try {
        final response = await _retry(pending.options, newToken);
        pending.handler.resolve(response);
      } catch (e) {
        pending.handler.reject(e as DioException);
      }
    }
  }

  void _rejectPending(DioException err) {
    for (final pending in _pendingRequests) {
      pending.handler.reject(err);
    }
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    debugPrint('[JwtInterceptor] Session expired → logging out');
    // navigate to login — هنربطها بالـ GoRouter بعدين
  }
}

// ── Helper class ────────────────────────────────────────────
class _PendingRequest {
  _PendingRequest(this.options, this.handler);
  final RequestOptions          options;
  final ErrorInterceptorHandler handler;
}
