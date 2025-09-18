import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Global error service for handling all app errors
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  /// Global scaffoldKey for showing snackbars
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Show error message to user (static method)
  static void showError(
    String message, {
    String? title,
    VoidCallback? onRetry,
  }) {
    _instance._showError(message, title: title, onRetry: onRetry);
  }

  /// Show success message to user (static method)
  static void showSuccess(String message) {
    _instance._showSuccess(message);
  }

  /// Show info message to user (static method)
  static void showInfo(String message) {
    _instance._showInfo(message);
  }

  /// Show error message to user (instance method)
  void _showError(String message, {String? title, VoidCallback? onRetry}) {
    if (kDebugMode) {
      debugPrint('ERROR: $title - $message');
    }

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show success message to user (instance method)
  void _showSuccess(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show info message to user (instance method)
  void _showInfo(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Handle different types of errors
  void handleError(dynamic error, {String? context, VoidCallback? onRetry}) {
    String message;
    String? title;

    if (error is NetworkException) {
      title = 'Connection Problem';
      message = error.message;
    } else if (error is ValidationException) {
      title = 'Validation Error';
      message = error.message;
    } else if (error is ServerException) {
      title = 'Server Error';
      message = 'Something went wrong on our end. Please try again.';
    } else {
      title = 'Unexpected Error';
      message = 'Something unexpected happened. Please try again.';
    }

    if (context != null) {
      message = '$message\n\nContext: $context';
    }

    showError(message, title: title, onRetry: onRetry);

    // Log error for debugging
    if (kDebugMode) {
      debugPrint('ERROR in $context: $error');
    }
  }
}

/// Custom exceptions
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (${statusCode ?? 'unknown'})';
}

/// Loading state management
class LoadingService with ChangeNotifier {
  static final LoadingService _instance = LoadingService._internal();
  factory LoadingService() => _instance;
  LoadingService._internal();

  final Map<String, bool> _loadingStates = {};

  bool isLoading(String key) => _loadingStates[key] ?? false;

  void setLoading(String key, bool loading) {
    _loadingStates[key] = loading;
    notifyListeners();
  }

  void clearLoading(String key) {
    _loadingStates.remove(key);
    notifyListeners();
  }

  bool get hasAnyLoading => _loadingStates.values.any((loading) => loading);
}

/// Loading widget for async operations
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
