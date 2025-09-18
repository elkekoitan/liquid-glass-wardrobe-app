import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/analytics_service.dart';
import '../services/auth_service.dart';

/// Represents the current status of the OTP entry flow.
enum OtpEntryStatus { idle, verifying, success, error }

/// Describes a verification method that the user can choose from.
class OtpMethod {
  const OtpMethod({
    required this.id,
    required this.label,
    required this.description,
    required this.type,
  });

  final String id;
  final String label;
  final String description;
  final String type;
}

/// Provider responsible for orchestrating OTP entry, timer states, and analytics.
class OtpProvider extends ChangeNotifier {
  OtpProvider({
    required this.capsuleId,
    required this.capsuleName,
    required this.capsuleMood,
    required this.heroCopy,
    this.themeVariant = 'classic',
    OtpMethod? initialMethod,
    List<OtpMethod>? availableMethods,
    Duration initialCountdown = const Duration(seconds: 60),
    AnalyticsService? analyticsService,
    AuthService? authService,
  }) : _analyticsService = analyticsService ?? AnalyticsService.instance,
       _authService = authService ?? AuthService.instance,
       _methods = List<OtpMethod>.unmodifiable(
         availableMethods ??
             const [
               OtpMethod(
                 id: 'sms',
                 label: 'SMS to ??45',
                 description: 'We texted a code to your number ending in ??45.',
                 type: 'sms',
               ),
               OtpMethod(
                 id: 'push',
                 label: 'Approve in app',
                 description: 'Tap approve on the push notification we sent.',
                 type: 'push',
               ),
               OtpMethod(
                 id: 'email',
                 label: 'Email to look@fitcheck.com',
                 description: 'Check your inbox for a fresh code.',
                 type: 'email',
               ),
             ],
       ),
       _activeMethod =
           initialMethod ??
           const OtpMethod(
             id: 'sms',
             label: 'SMS to ??45',
             description: 'We texted a code to your number ending in ??45.',
             type: 'sms',
           ),
       _secondsRemaining = initialCountdown.inSeconds {
    if (!_methods.any((method) => method.id == _activeMethod.id)) {
      _methods = List<OtpMethod>.unmodifiable(<OtpMethod>[
        ..._methods,
        _activeMethod,
      ]);
    }

    _analyticsService.logEvent(
      'otp_view',
      parameters: {
        'capsule_id': capsuleId,
        'theme_variant': themeVariant,
        'method': _activeMethod.id,
      },
    );

    _startTimer();
  }

  static const int codeLength = 6;

  final AnalyticsService _analyticsService;
  final AuthService _authService;

  final String capsuleId;
  final String capsuleName;
  final String capsuleMood;
  final String heroCopy;
  final String themeVariant;

  List<OtpMethod> _methods;
  OtpMethod _activeMethod;

  String _code = '';
  int _secondsRemaining;
  bool _resendInFlight = false;
  OtpEntryStatus _status = OtpEntryStatus.idle;
  String? _errorMessage;
  Timer? _timer;
  bool _disposed = false;

  String get code => _code;
  List<String> get digits => List<String>.generate(codeLength, (index) {
    return index < _code.length ? _code[index] : '';
  });
  List<OtpMethod> get methods => _methods;
  OtpMethod get activeMethod => _activeMethod;
  int get secondsRemaining => _secondsRemaining;
  bool get isTimerExpired => _secondsRemaining <= 0;
  bool get canResend => isTimerExpired && !_resendInFlight;
  bool get isResendInFlight => _resendInFlight;
  OtpEntryStatus get status => _status;
  bool get isVerifying => _status == OtpEntryStatus.verifying;
  bool get isSuccess => _status == OtpEntryStatus.success;
  bool get hasError => _status == OtpEntryStatus.error;
  String? get errorMessage => _errorMessage;

  String get formattedTimer {
    final duration = Duration(seconds: _secondsRemaining.clamp(0, 599));
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Handles raw text input from the hidden text field.
  void handleInput(String rawInput) {
    final sanitized = rawInput.replaceAll(RegExp(r'[^0-9]'), '');
    final truncated = sanitized.length > codeLength
        ? sanitized.substring(0, codeLength)
        : sanitized;

    if (_code == truncated) {
      return;
    }

    final previousLength = _code.length;
    _code = truncated;

    if (_status == OtpEntryStatus.error) {
      _status = OtpEntryStatus.idle;
      _errorMessage = null;
    }

    if (_code.length > previousLength) {
      final index = _code.length - 1;
      _analyticsService.logEvent(
        'otp_digit_entered',
        parameters: {
          'digit_index': index + 1,
          'method': _activeMethod.id,
          'capsule_id': capsuleId,
        },
      );
    }

    notifyListeners();

    if (_code.length == codeLength) {
      _submitCode();
    }
  }

  /// Clears the current code input.
  void clearCode() {
    if (_code.isEmpty) return;
    _code = '';
    _status = OtpEntryStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Initiates verification of the entered code.
  Future<void> _submitCode() async {
    if (_status == OtpEntryStatus.verifying) {
      return;
    }

    _status = OtpEntryStatus.verifying;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.verifyOtpCode(code: _code);

    if (!result.success) {
      _status = OtpEntryStatus.error;
      _errorMessage = result.error ?? 'Digits did not align. Let\'s try again.';
      _analyticsService.logEvent(
        'otp_error',
        parameters: {
          'method': _activeMethod.id,
          'capsule_id': capsuleId,
          'theme_variant': themeVariant,
        },
      );
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 800));
      if (_disposed) return;
      _code = '';
      _status = OtpEntryStatus.idle;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _status = OtpEntryStatus.success;
    _analyticsService.logEvent(
      'otp_success',
      parameters: {
        'method': _activeMethod.id,
        'capsule_id': capsuleId,
        'theme_variant': themeVariant,
        'completion_time': 60 - _secondsRemaining,
      },
    );
    notifyListeners();
  }

  /// Requests a new OTP code and restarts the timer.
  Future<void> resendCode() async {
    if (!canResend || _resendInFlight) {
      return;
    }

    _resendInFlight = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _analyticsService.logEvent(
      'otp_resend',
      parameters: {'method': _activeMethod.id, 'capsule_id': capsuleId},
    );

    _resendInFlight = false;
    _code = '';
    _status = OtpEntryStatus.idle;
    _errorMessage = null;
    _secondsRemaining = 60;
    _startTimer();
    notifyListeners();
  }

  /// Switches the active verification method.
  void selectMethod(String id) {
    final target = _methods.firstWhere(
      (method) => method.id == id,
      orElse: () => _activeMethod,
    );

    if (target.id == _activeMethod.id) {
      return;
    }

    _activeMethod = target;
    _code = '';
    _status = OtpEntryStatus.idle;
    _errorMessage = null;
    _secondsRemaining = 60;
    _startTimer();

    _analyticsService.logEvent(
      'otp_method_switch',
      parameters: {
        'method': _activeMethod.id,
        'capsule_id': capsuleId,
        'theme_variant': themeVariant,
      },
    );

    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_secondsRemaining <= 0) {
      _secondsRemaining = 0;
      notifyListeners();
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        notifyListeners();
        return;
      }
      _secondsRemaining -= 1;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
