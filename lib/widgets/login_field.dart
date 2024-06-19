import 'package:flutter/material.dart';
import '../pallete.dart';

class LoginField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon; // Dodanie tego parametru

  const LoginField({
    Key? key,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onSaved,
    this.validator,
    this.suffixIcon,
  }) : super(key: key);

  @override
  _LoginFieldState createState() => _LoginFieldState();
}

class _LoginFieldState extends State<LoginField> {
  final ValueNotifier<bool> _hasError = ValueNotifier<bool>(false);
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _hasError,
        builder: (context, hasError, child) {
          return TextFormField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(27),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Pallete.borderColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Pallete.gradient2,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: hasError ? _errorText : widget.hintText,
              hintStyle: TextStyle(
                color: hasError ? Colors.red : Colors.grey,
              ),
              errorStyle: const TextStyle(height: 0), // Hide error text
              suffixIcon: widget.suffixIcon, // Dodanie ikony suffix
            ),
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            onSaved: widget.onSaved,
            validator: (value) {
              final error = widget.validator?.call(value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _hasError.value = error != null;
                _errorText = error;
              });
              return null; // Return null to prevent displaying error text under the field
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          );
        },
      ),
    );
  }
}
