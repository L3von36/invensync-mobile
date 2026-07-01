import 'dart:math';
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
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
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

  bool get _isWide => MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isWide) {
      return Scaffold(
        body: Row(
          children: [
            // Left branding panel
            _buildBrandingPanel(context, isDark),
            // Right form panel
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildFormCard(context, isDark),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildFormCard(context, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingPanel(BuildContext context, bool isDark) {
    return Container(
      width: 420,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A8A),
            const Color(0xFF1E40AF),
            const Color(0xFF2563EB),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Animated logo
          Transform.rotate(
            angle: -0.05,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'InvenSync',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Offline-first inventory & sales management for modern businesses',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Feature pills
          _buildFeaturePill(Icons.wifi_off, 'Works Offline'),
          const SizedBox(height: 10),
          _buildFeaturePill(Icons.sync, 'Auto Sync'),
          const SizedBox(height: 10),
          _buildFeaturePill(Icons.speed, 'Real-time'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isDark) {
    final maxW = _isWide ? 400.0 : double.infinity;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isWide) ...[
            // Mobile: show logo on top
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 36, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to your InvenSync account',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ] else ...[
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to continue to InvenSync',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
          const SizedBox(height: 36),

          // Error
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_error!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                  ),
                ],
              ),
            ),
          if (_error != null) const SizedBox(height: 20),

          // Email field
          _buildLabel('Email'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'you@company.com',
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade400),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password field
          _buildLabel('Password'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey.shade400),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            onFieldSubmitted: (_) => _login(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Min 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Forgot password (placeholder)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: AppTheme.primaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Sign In button
          FilledButton(
            onPressed: _isLoading ? null : _login,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Sign In'),
          ),
          const SizedBox(height: 16),

          // Demo button
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _fillDemo,
            icon: Icon(Icons.science_outlined, size: 18, color: AppTheme.secondaryColor),
            label: Text(
              'Fill Demo Credentials',
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Try Demo Mode button
          TextButton.icon(
            onPressed: _isLoading ? null : _startDemo,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text(
              'Try Demo Mode (no server needed)',
              style: TextStyle(fontSize: 13),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              foregroundColor: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }
}