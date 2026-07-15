import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/islamic_pattern_background.dart';
import '../../widgets/auth_text_fields.dart';
import '../../widgets/premium_background.dart';

/// Premium dark login — styles aligned to the dashboard glass aesthetic.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          ),
        ),
      );
    }
  }

  void _showForgotPassword() {
    final l10n = AppLocalizations.of(context);
    final emailCtrl = TextEditingController(text: _emailController.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navyCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.forgotPassword,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your email and we will send reset instructions.',
                style: TextStyle(color: Color(0x80FFFFFF), fontSize: 13),
              ),
              const SizedBox(height: 20),
              _LoginLabeledField(
                label: l10n.email,
                child: TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: _LoginStyles.inputText,
                  decoration: _LoginStyles.inputDecoration(
                    hint: kIsWeb ? 'name@example.com' : null,
                    prefix: Icons.email_outlined,
                  ),
                  validator: validateEmail,
                ),
              ),
              const SizedBox(height: 20),
              _GradientLoginButton(
                label: 'Send reset link',
                onPressed: () async {
                  final auth = ctx.read<AuthProvider>();
                  final ok = await auth.sendPasswordReset(emailCtrl.text.trim());
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Reset email sent'
                            : (auth.error ?? 'Could not send reset email'),
                      ),
                      backgroundColor: ok ? AppColors.success : AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: IslamicPatternBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: PremiumPage(
                maxWidth: 420,
                padding: EdgeInsets.zero,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      // headerContainer
                      Column(
                        children: [
                          // logoBadge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: AppDecorations.brandGradient,
                              boxShadow: AppDecorations.purpleGlow,
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
                          // welcomeText
                          Text(
                            l10n.welcomeBack,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // subtitleText
                          Text(
                            l10n.appTagline,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0x80FFFFFF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Email
                      _LoginLabeledField(
                        label: l10n.email,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          smartDashesType: SmartDashesType.disabled,
                          smartQuotesType: SmartQuotesType.disabled,
                          autofillHints:
                              kIsWeb ? null : const [AutofillHints.email],
                          style: _LoginStyles.inputText,
                          decoration: _LoginStyles.inputDecoration(
                            hint: kIsWeb ? 'name@example.com' : null,
                            prefix: Icons.email_outlined,
                          ),
                          validator: validateEmail,
                          onFieldSubmitted: (_) => _login(),
                        ),
                      ),

                      // Password
                      _LoginLabeledField(
                        label: l10n.password,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints:
                              kIsWeb ? null : const [AutofillHints.password],
                          style: _LoginStyles.inputText,
                          decoration: _LoginStyles.inputDecoration(
                            prefix: Icons.lock_outlined,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0x80FFFFFF),
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: validatePassword,
                          onFieldSubmitted: (_) => _login(),
                        ),
                      ),

                      // forgotBtn
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.forgotPassword,
                            style: const TextStyle(
                              color: Color(0xFF36D8FF),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // buttonWrapper + loginButton
                      _GradientLoginButton(
                        label: l10n.login,
                        loading: auth.isLoading,
                        onPressed: _login,
                      ),
                      const SizedBox(height: 20),

                      // footerRow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.noAccount,
                            style: const TextStyle(
                              color: Color(0x80FFFFFF),
                              fontSize: 13,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              l10n.register,
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
    );
  }
}

class _LoginLabeledField extends StatelessWidget {
  const _LoginLabeledField({required this.label, required this.child});

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
            textAlign: TextAlign.start,
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

class _GradientLoginButton extends StatelessWidget {
  const _GradientLoginButton({
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
          gradient: loading ? null : AppDecorations.brandGradient,
          color: loading ? AppColors.primaryGreen.withValues(alpha: 0.35) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: loading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.pink.withValues(alpha: 0.35),
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

class _LoginStyles {
  static const inputText = TextStyle(color: Colors.white, fontSize: 14);

  static InputDecoration inputDecoration({
    String? hint,
    IconData? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0x0DFFFFFF), // rgba(255,255,255,0.05)
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0x66FFFFFF), fontSize: 14),
      prefixIcon: prefix == null
          ? null
          : Icon(prefix, color: const Color(0x80FFFFFF), size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x14FFFFFF)), // 0.08
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x14FFFFFF)),
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
