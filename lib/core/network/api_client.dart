import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:securemail/core/network/jwt_interceptor.dart';

class ApiClient {
  ApiClient._();

  static Dio? _dio;
  static Future<void> Function()? _onLogoutCallback;

  // ── Logout Callback ──────────────────────────────────────
  /// اربطه من main.dart قبل runApp:
  /// ApiClient.setLogoutCallback(() async { router.go('/login'); });
  static void setLogoutCallback(Future<void> Function() cb) {
    _onLogoutCallback = cb;
  }

  // ── Dio Singleton ────────────────────────────────────────
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl:        ApiConstants.baseUrlDev, // غيّره لـ baseUrl في Production
        connectTimeout: Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        headers: {
          ApiConstants.headerContentType: ApiConstants.jsonContentType,
          ApiConstants.headerAccept:      ApiConstants.jsonContentType,
        },
      ),
    );

    dio.interceptors.addAll([
      JwtInterceptor(dio, onLogout: _onLogoutCallback),
      _buildLogInterceptor(),
    ]);

    return dio;
  }

  static LogInterceptor _buildLogInterceptor() => LogInterceptor(
    requestBody:   true,
    responseBody:  true,
    requestHeader: true,
    error:         true,
    logPrint: (log) => debugPrint('[API] $log'),
  );

  // ── Static HTTP Methods ───────────────────────────────────

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      instance.get(path, queryParameters: queryParameters, options: options);

  static Future<Response> post(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      instance.post(path, data: data, options: options);

  static Future<Response> put(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      instance.put(path, data: data, options: options);

  static Future<Response> patch(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      instance.patch(path, data: data, options: options);

  static Future<Response> delete(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      instance.delete(path, data: data, options: options);

  // ── Reset (للـ testing) ───────────────────────────────────
  static void reset() => _dio = null;
}