import 'package:flutter/material.dart';

class ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final Color? focusColor;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.focusColor,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isObscured = false;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _hasText = widget.controller.text.isNotEmpty;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: widget.focusColor ?? Colors.blue.shade400,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _isFocused 
                      ? (widget.focusColor ?? Colors.blue).withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: _isFocused ? 20 : 10,
                  offset: const Offset(0, 5),
                  spreadRadius: _isFocused ? 2 : 0,
                ),
              ],
              border: Border.all(
                color: _colorAnimation.value ?? Colors.grey.shade300,
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              obscureText: _isObscured,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              onTap: () {
                setState(() {
                  _isFocused = true;
                });
                _animationController.forward();
              },
              onTapOutside: (_) {
                setState(() {
                  _isFocused = false;
                });
                _animationController.reverse();
              },
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                filled: false,
                labelText: widget.label,
                hintText: widget.hintText,
                labelStyle: TextStyle(
                  color: _isFocused 
                      ? widget.focusColor ?? Colors.blue.shade600
                      : Colors.grey.shade600,
                  fontSize: _isFocused || _hasText ? 14 : 16,
                  fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          widget.prefixIcon,
                          color: _isFocused 
                              ? widget.focusColor ?? Colors.blue.shade600
                              : Colors.grey.shade500,
                          size: 22,
                        ),
                      )
                    : null,
                suffixIcon: widget.obscureText
                    ? IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            key: ValueKey(_isObscured),
                            color: _isFocused 
                                ? widget.focusColor ?? Colors.blue.shade600
                                : Colors.grey.shade500,
                            size: 22,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
            ),
          ),
        );
      },
    );
  }
}