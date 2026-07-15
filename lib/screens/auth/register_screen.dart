import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_text_fields.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _obscure = true;
  late AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      role: _selectedRole,
    );
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registration failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF070B1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Glowing background blur circles
          Positioned(
            top: -80,
            right: -40,
            child: _GlowOrb(
              size: 260,
              color: const Color(0xFF7B5CFF).withValues(alpha: 0.35),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -60,
            child: _GlowOrb(
              size: 220,
              color: const Color(0xFFFF5FA2).withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            top: 280,
            right: 40,
            child: _GlowOrb(
              size: 140,
              color: const Color(0xFF36D8FF).withValues(alpha: 0.12),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => context.go('/login'),
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.06),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Header
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF7B5CFF),
                                      Color(0xFFFF5FA2),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7B5CFF)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  l10n.appTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Text(
                                l10n.createAccount,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.appTagline,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Frosted glass card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Name
                                    _LabeledField(
                                      label: l10n.displayName,
                                      child: TextFormField(
                                        controller: _nameController,
                                        textInputAction: TextInputAction.next,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        style: _fieldTextStyle,
                                        decoration: _inputDecoration(
                                          prefix: Icons.person_outlined,
                                        ),
                                        validator: (v) =>
                                            v == null || v.isEmpty
                                                ? 'Required'
                                                : null,
                                      ),
                                    ),

                                    // Email
                                    _LabeledField(
                                      label: l10n.email,
                                      child: TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        smartDashesType:
                                            SmartDashesType.disabled,
                                        smartQuotesType:
                                            SmartQuotesType.disabled,
                                        autofillHints: kIsWeb
                                            ? null
                                            : const [AutofillHints.email],
                                        style: _fieldTextStyle,
                                        decoration: _inputDecoration(
                                          hint: kIsWeb
                                              ? 'name@example.com'
                                              : null,
                                          prefix: Icons.email_outlined,
                                        ),
                                        validator: validateEmail,
                                      ),
                                    ),

                                    // Password
                                    _LabeledField(
                                      label: l10n.password,
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscure,
                                        textInputAction: TextInputAction.done,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        autofillHints: kIsWeb
                                            ? null
                                            : const [AutofillHints.password],
                                        style: _fieldTextStyle,
                                        decoration: _inputDecoration(
                                          prefix: Icons.lock_outlined,
                                          suffix: IconButton(
                                            icon: Icon(
                                              _obscure
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: Colors.white
                                                  .withValues(alpha: 0.5),
                                              size: 20,
                                            ),
                                            onPressed: () => setState(
                                              () => _obscure = !_obscure,
                                            ),
                                          ),
                                        ),
                                        validator: validatePassword,
                                        onFieldSubmitted: (_) => _register(),
                                      ),
                                    ),

                                    const Text(
                                      'I am a',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _RoleSelector(
                                      selected: _selectedRole,
                                      onChanged: (role) => setState(
                                        () => _selectedRole = role,
                                      ),
                                    ),
                                    if (_selectedRole == UserRole.teacher) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: AppColors.warning
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.info_outline_rounded,
                                              color: AppColors.warning,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Teacher accounts require admin approval',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 24),

                                    // Sign Up gradient button
                                    _SignUpButton(
                                      label: l10n.register,
                                      loading: auth.isLoading,
                                      onPressed: _register,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Footer → Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.hasAccount,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 13,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  l10n.login,
                                  style: const TextStyle(
                                    color: Color(0xFFFF5FA2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _fieldTextStyle = TextStyle(color: Colors.white, fontSize: 14);

  InputDecoration _inputDecoration({
    String? hint,
    IconData? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 14,
      ),
      prefixIcon: prefix == null
          ? null
          : Icon(prefix, color: Colors.white.withValues(alpha: 0.5), size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF7B5CFF), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: loading
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF7B5CFF), Color(0xFFFF5FA2)],
                ),
          color: loading
              ? const Color(0xFF7B5CFF).withValues(alpha: 0.35)
              : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: loading
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFFF5FA2).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selected,
    required this.onChanged,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleChip(
            label: 'Student',
            icon: Icons.school_outlined,
            isSelected: selected == UserRole.student,
            onTap: () => onChanged(UserRole.student),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RoleChip(
            label: 'Teacher',
            icon: Icons.person_outline,
            isSelected: selected == UserRole.teacher,
            onTap: () => onChanged(UserRole.teacher),
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF7B5CFF), Color(0xFFFF5FA2)],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
