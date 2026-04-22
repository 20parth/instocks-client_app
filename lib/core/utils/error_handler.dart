import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

/// Global error handler for API and app errors
class ErrorHandler {
  /// Convert DioException to user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';

        case DioExceptionType.badResponse:
          return _handleStatusCode(
              error.response?.statusCode, error.response?.data);

        case DioExceptionType.cancel:
          return 'Request was cancelled.';

        case DioExceptionType.connectionError:
          return 'Unable to connect to server. Please check your internet connection.';

        case DioExceptionType.badCertificate:
          return 'Security certificate error. Please contact support.';

        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') ?? false) {
            return 'No internet connection. Please check your network.';
          }
          return 'An unexpected error occurred. Please try again.';
      }
    }

    // Non-Dio errors
    return error?.toString() ?? 'An unexpected error occurred.';
  }

  /// Handle HTTP status codes
  static String _handleStatusCode(int? statusCode, dynamic responseData) {
    // Try to extract message from response
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] as String?;
    }

    switch (statusCode) {
      case 400:
        return serverMessage ?? 'Invalid request. Please check your input.';
      case 401:
        return serverMessage ?? 'Invalid credentials. Please try again.';
      case 403:
        return serverMessage ?? 'Access denied. You don\'t have permission.';
      case 404:
        return serverMessage ?? 'Resource not found.';
      case 422:
        return serverMessage ?? 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return serverMessage ?? 'Something went wrong. Please try again.';
    }
  }

  /// Show error toast message
  static void showErrorToast(dynamic error) {
    final message = getErrorMessage(error);
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red.shade900,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show success toast message
  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green.shade900,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show info toast message
  static void showInfoToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.blue.shade900,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show warning toast message
  static void showWarningToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.orange.shade900,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
