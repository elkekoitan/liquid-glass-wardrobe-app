import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_tokens.dart';

/// Glass morphism text field with liquid glass effects
/// Provides a consistent input experience with glass aesthetics
class GlassTextField extends StatefulWidget {
  /// Controller for the text field
  final TextEditingController? controller;

  /// Placeholder text
  final String? hintText;

  /// Label text
  final String? labelText;

  /// Error text to display
  final String? errorText;

  /// Whether the text field is obscured (for passwords)
  final bool obscureText;

  /// Icon to display before the input
  final IconData? prefixIcon;

  /// Widget to display after the input
  final Widget? suffixIcon;

  /// Text input type
  final TextInputType keyboardType;

  /// Text input action
  final TextInputAction textInputAction;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is read-only
  final bool readOnly;

  /// Maximum number of lines
  final int maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Maximum length of text
  final int? maxLength;

  /// Validation function
  final String? Function(String?)? validator;

  /// Callback when text changes
  final void Function(String)? onChanged;

  /// Callback when field is submitted
  final void Function(String)? onFieldSubmitted;

  /// Callback when field is tapped
  final VoidCallback? onTap;

  /// Focus node for the text field
  final FocusNode? focusNode;

  /// Text input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Auto focus
  final bool autofocus;

  /// Auto fill hints
  final Iterable<String>? autofillHints;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  /// Text alignment
  final TextAlign textAlign;

  /// Style of the input text
  final TextStyle? style;

  const GlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.focusNode,
    this.inputFormatters,
    this.autofocus = false,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.style,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late Animation<Color?> _borderColorAnimation;

  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _errorText = widget.errorText;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.white.withValues(alpha: 0.2),
      end: AppColors.primaryMain.withValues(alpha: 0.8),
    ).animate(_animationController);

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        // Validate on focus loss if validator is provided
        if (widget.validator != null) {
          final error = widget.validator!(widget.controller?.text);
          if (error != _errorText) {
            setState(() {
              _errorText = error;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: DesignTokens.spaceS,
              bottom: DesignTokens.spaceXS,
            ),
            child: Text(
              widget.labelText!,
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                border: Border.all(
                  color: _errorText != null
                      ? AppColors.errorMain.withValues(alpha: 0.8)
                      : _borderColorAnimation.value!,
                  width: _isFocused ? 2.0 : 1.0,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(
                      alpha: 0.1 + (_focusAnimation.value * 0.05),
                    ),
                    Colors.white.withValues(
                      alpha: 0.05 + (_focusAnimation.value * 0.03),
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primaryMain.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onFieldSubmitted,
                onTap: widget.onTap,
                inputFormatters: widget.inputFormatters,
                autofocus: widget.autofocus,
                autofillHints: widget.autofillHints,
                textCapitalization: widget.textCapitalization,
                textAlign: widget.textAlign,
                style:
                    widget.style ??
                    AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  border: InputBorder.none,
                  errorBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceL,
                    vertical: DesignTokens.spaceM,
                  ),
                  counterText: '', // Hide character counter
                  errorText: null, // We handle error display ourselves
                ),
                validator: widget.validator,
              ),
            );
          },
        ),
        if (_errorText != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: DesignTokens.spaceS,
              top: DesignTokens.spaceXS,
            ),
            child: Text(
              _errorText!,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.errorMain,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Specialized glass text field for OTP input
class GlassOTPTextField extends StatelessWidget {
  final TextEditingController? controller;
  final int length;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  const GlassOTPTextField({
    super.key,
    this.controller,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.focusNode,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassTextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.center,
      maxLength: length,
      style: AppTextStyles.displayMedium.copyWith(
        color: Colors.white,
        letterSpacing: DesignTokens.spaceM,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        onChanged?.call(value);
        if (value.length == length) {
          onCompleted?.call(value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the verification code';
        }
        if (value.length < length) {
          return 'Please enter all $length digits';
        }
        return null;
      },
    );
  }
}

/// Glass text field with search functionality
class GlassSearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool showClearButton;

  const GlassSearchTextField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: Icons.search,
      suffixIcon:
          showClearButton && controller != null && controller!.text.isNotEmpty
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
              onPressed:
                  onClear ??
                  () {
                    controller?.clear();
                    onChanged?.call('');
                  },
            )
          : null,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
    );
  }
}
