import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class LoginScreen extends StatefulWidget {
  final void Function() onLoginSuccess;
  final void Function(String token) on2FaRequired;
  final Future<void> Function() onStartDemo;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.on2FaRequired,
    required this.onStartDemo,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _fillDemo() {
    setState(() {
      _emailController.text = 'demo@invensync.com';
      _passwordController.text = 'demo1234';
      _error = null;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      widget.onLoginSuccess();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startDemo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await widget.onStartDemo();
  }

  // ── Branding panel (left side on wide screens, header on narrow) ──

  Widget _buildBrandingPanel({required bool isCompact}) {
    if (isCompact) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 36),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 26,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'InvenSync',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Smart Inventory Management',
              style: TextStyle(
                color: Color(0xFFFEF3C7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    // Full branding panel for wide screens
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.cardRadiusLg),
          bottomLeft: Radius.circular(AppTheme.cardRadiusLg),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'InvenSync',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Smart Inventory Management',
            style: TextStyle(
              color: Color(0xFFFEF3C7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          _buildFeatureBullet(
            text: 'Works fully offline — sync when connected',
          ),
          const SizedBox(height: 16),
          _buildFeatureBullet(
            text: 'Real-time stock tracking & low-stock alerts',
          ),
          const SizedBox(height: 16),
          _buildFeatureBullet(
            text: 'Integrated sales, purchases & reporting',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet({required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Form panel ──

  Widget _buildFormPanel({required bool isDark}) {
    final textColor =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary;
    final mutedColor =
        isDark ? AppTheme.textTertiaryDark : AppTheme.mutedText;
    final secondaryTextColor =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
    final inputFillColor = isDark
        ? AppTheme.surfaceDark
        : const Color(0xFFF8FAFC);
    final inputBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE2E8F0);
    final inputFocusColor = isDark
        ? AppTheme.primaryLight
        : AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadiusLg),
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.08))
            : null,
        boxShadow: isDark ? null : AppTheme.shadowXl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Error banner ──
            if (_error != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF450A0A).withValues(alpha: 0.6)
                      : AppTheme.errorBg,
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF7F1D1D).withValues(alpha: 0.5)
                        : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: isDark
                          ? const Color(0xFFFCA5A5)
                          : AppTheme.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFFCA5A5)
                              : AppTheme.errorText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (!isDark)
                      const SizedBox(width: 4),
                    if (!isDark)
                      Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppTheme.errorText.withValues(alpha: 0.5),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Title (mobile only, hidden on split) ──
            // Title is shown in the branding panel on wide screens.

            // ── Email field ──
            Text(
              'Email',
              style: AppTheme.overline.copyWith(color: secondaryTextColor),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputFillColor,
                hintText: 'you@company.com',
                prefixIcon: Icon(Icons.email_outlined, color: mutedColor, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  borderSide: BorderSide(color: inputFocusColor, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  borderSide: const BorderSide(color: AppTheme.errorColor),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  borderSide:
                      const BorderSide(color: AppTheme.errorColor, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Password field ──
            Text(
              'Password',
              style: AppTheme.overline.copyWith(color: secondaryTextColor),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _login(),
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputFillColor,
                hintText: 'Enter your password',
                prefixIcon:
                    Icon(Icons.lock_outlined, color: mutedColor, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: mutedColor,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  splashRadius: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  borderSide: BorderSide(color: inputFocusColor, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  borderSide: const BorderSide(color: AppTheme.errorColor),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  borderSide:
                      const BorderSide(color: AppTheme.errorColor, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Forgot password ──
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Sign In button ──
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _isLoading ? null : _login,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor:
                      AppTheme.primaryColor.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.buttonRadius),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          height: 1,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Divider ──
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or continue with',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0),
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Fill Demo Credentials ──
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _fillDemo,
                icon: Icon(
                  Icons.science_outlined,
                  size: 18,
                  color: AppTheme.successColor,
                ),
                label: Text(
                  'Fill Demo Credentials',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppTheme.successColor.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Try Demo Mode ──
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _isLoading ? null : _startDemo,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text(
                  'Try Demo Mode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Sign up link ──
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: mutedColor,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: "Don't have an account? "),
                  TextSpan(
                    text: 'Sign Up',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Responsive layout builder ──

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    // Scaffold background
    final bgColor = isDark ? AppTheme.backgroundDark : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Center(
            child: isWide
                ? _buildWideLayout(isDark: isDark)
                : _buildNarrowLayout(isDark: isDark),
          ),
        ),
      ),
    );
  }

  // ── Wide: split layout ──

  Widget _buildWideLayout({required bool isDark}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branding panel — fixed width
                Flexible(
                  flex: 5,
                  child: _buildBrandingPanel(isCompact: false),
                ),
                const SizedBox(width: 0),
                // Form panel
                Flexible(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: SingleChildScrollView(
                        child: _buildFormPanel(isDark: isDark),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Narrow: stacked layout ──

  Widget _buildNarrowLayout({required bool isDark}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          _buildBrandingPanel(isCompact: true),
          const SizedBox(height: 28),
          _buildFormPanel(isDark: isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}