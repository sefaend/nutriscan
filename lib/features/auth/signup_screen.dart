import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/features/auth/auth_screen.dart';
import 'package:nutri_scan/router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: cs.onSurface)),
        backgroundColor: isError ? cs.error : cs.primary,
      ),
    );
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnack('Please fill in all fields!', isError: true);
      return;
    }
    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters!', isError: true);
      return;
    }
    if (password != confirm) {
      _showSnack('Passwords do not match!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        username: name,
        email: email,
        password: password,
      );

      _showSnack('Account created successfully!', isError: false);

      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      _showSnack('Error: ${e.toString()}!!', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: cs.surfaceContainer,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = math.max(constraints.maxHeight, 640.0);

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ClipRRect(
                child: Container(
                  height: cardHeight,
                  width: double.infinity,
                  color: cs.onSurface,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _BlobPainter(
                            light: cs.onSurfaceVariant,
                            mid: cs.primary,
                            dark: cs.onPrimary,
                          ),
                        ),
                      ),
                      //MAYBE REMOVE---------------------
                      Positioned(
                        top: 12,
                        left: 8,
                        child: IconButton(
                          onPressed: () => context.go(AppRoutes.home),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 22,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                      //----------------------------------

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(flex: 2),
                            Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: cs.tertiary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Please fill in to sign up.',
                              style: TextStyle(
                                fontSize: 14,
                                color: cs.tertiaryContainer,
                              ),
                            ),
                            const SizedBox(height: 28),

                            _InputField(
                              controller: _nameController,
                              label: 'USERNAME',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 14),
                            _InputField(
                              controller: _emailController,
                              label: 'EMAIL',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            _InputField(
                              controller: _passwordController,
                              label: 'PASSWORD',
                              icon: Icons.lock_outline,
                              obscure: true,
                            ),
                            const SizedBox(height: 14),
                            _InputField(
                              controller: _confirmController,
                              label: 'CONFIRM PASSWORD',
                              icon: Icons.lock_outline,
                              obscure: true,
                            ),
                            const SizedBox(height: 28),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _GradientButton(
                                isLoading: _isLoading,
                                onTap: () {
                                  if (!_isLoading) _handleSignup();
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.apple,
                                    size: 32,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.facebook,
                                    size: 32,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                IconButton(
                                  onPressed: () {},
                                  icon: FaIcon(
                                    FontAwesomeIcons.google,
                                    size: 28,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(flex: 3),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.tertiaryContainer,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.go('/login');
                                    },
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: cs.onSurface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: cs.tertiary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.tertiary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              maxLines: 1,
              style: TextStyle(
                color: cs.tertiary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: label,

                hintStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onTertiary,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GradientButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [cs.primary, cs.onPrimary]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 10),
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSurface,
                    strokeWidth: 4,
                  ),
                  SizedBox(width: 10),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.arrow_forward, color: cs.onSurface, size: 18),
                ],
              ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Color light;
  final Color mid;
  final Color dark;

  _BlobPainter({required this.light, required this.mid, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [mid, light],
      ).createShader(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h * 0.2));

    final top = Path()
      ..moveTo(w * 0.55, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.17)
      ..cubicTo(w * 0.85, h * 0.2, w * 0.7, h * 0.14, w * 0.62, h * 0.08)
      ..cubicTo(w * 0.58, h * 0.05, w * 0.55, h * 0.03, w * 0.55, 0)
      ..close();

    canvas.save();
    canvas.translate(w, 0);
    canvas.scale(-1, 1);
    canvas.drawPath(top, topPaint);
    canvas.restore();

    final sidePaint = Paint()..color = dark.withValues(alpha: 0.85);
    final side = Path()
      ..moveTo(w, h * 0.5)
      ..cubicTo(w * 0.93, h * 0.52, w * 0.9, h * 0.6, w, h * 0.68)
      ..close();
    canvas.drawPath(side, sidePaint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) =>
      old.light != light || old.mid != mid || old.dark != dark;
}
