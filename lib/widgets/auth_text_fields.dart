import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  final email = value.trim();
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(email)) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Required';
  }
  if (value.length < 6) {
    return 'Min 6 characters';
  }
  return null;
}

/// Email field tuned for Flutter Web (@ paste/type bug workaround).
class NaseemEmailField extends StatelessWidget {
  const NaseemEmailField({
    super.key,
    required this.controller,
    required this.label,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      autofillHints: kIsWeb ? null : const [AutofillHints.email],
      decoration: InputDecoration(
        labelText: label,
        hintText: kIsWeb ? 'name@example.com' : null,
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      validator: validateEmail,
      onFieldSubmitted: onSubmitted,
    );
  }
}

class NaseemPasswordField extends StatefulWidget {
  const NaseemPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  @override
  State<NaseemPasswordField> createState() => _NaseemPasswordFieldState();
}

class _NaseemPasswordFieldState extends State<NaseemPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: kIsWeb ? null : const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: validatePassword,
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}
