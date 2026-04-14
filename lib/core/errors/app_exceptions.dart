import 'package:dio/dio.dart';

/// Base exception للمشروع كله
abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

// ── Network Exceptions ──────────────────────────────────────

/// مفيش إنترنت
class NoInternetException extends AppException {
  const NoInternetException()
      : super('No internet connection. Please check your network.');
}

/// الـ server مردش في الوقت المحدد
class TimeoutException extends AppException {
  const TimeoutException()
      : super('Request timed out. Please try again.');
}

/// خطأ من الـ server
class ServerException extends AppException {
  const ServerException({
    required this.statusCode,
    String message = 'Something went wrong. Please try again.',
  }) : super(message);

  final int statusCode;
}

/// مش مصرح — Token منتهي أو غلط
class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('Session expired. Please log in again.');
}

/// مش موجود
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.']);
}

/// الـ request غلط
class BadRequestException extends AppException {
  const BadRequestException([super.message = 'Invalid request.']);
}

/// خطأ في الـ parsing
class ParseException extends AppException {
  const ParseException()
      : super('Failed to parse server response.');
}

/// خطأ مجهول
class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}

// ── Auth Exceptions ─────────────────────────────────────────

class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException()
      : super('Invalid email or password.');
}

class EmailAlreadyExistsException extends AppException {
  const EmailAlreadyExistsException()
      : super('An account with this email already exists.');
}

class WeakPasswordException extends AppException {
  const WeakPasswordException()
      : super('Password is too weak. Use at least 8 characters.');
}

// ── Converter ───────────────────────────────────────────────

/// بيحوّل أي DioException لـ AppException مفهومة
AppException dioExceptionToAppException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutException();

    case DioExceptionType.connectionError:
      return const NoInternetException();

    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode ?? 0;
      final message    = _extractMessage(e.response);

      switch (statusCode) {
        case 400: return BadRequestException(message);
        case 401: return const UnauthorizedException();
        case 404: return NotFoundException(message);
        case 422: return BadRequestException(message);
        default:  return ServerException(statusCode: statusCode, message: message);
      }

    default:
      return const UnknownException();
  }
}

String _extractMessage(Response? response) {
  try {
    final data = response?.data;
    if (data is Map) {
      return data['message'] as String? ??
             data['error']   as String? ??
             'Something went wrong.';
    }
  } catch (_) {}
  return 'Something went wrong.';
}
