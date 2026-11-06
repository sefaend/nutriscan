import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/features/auth/auth_screen.dart';
import 'package:nutri_scan/router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
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

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnack('Please enter your email address!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(email);
      _showSnack('Password reset link sent to your email!', isError: false);
      if (mounted && context.canPop()) {
        context.pop();
      }
    } catch (e) {
      _showSnack('Error: ${e.toString()}!!', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxHeight;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ClipRRect(
                child: Container(
                  height: cardHeight < 560 ? 560 : cardHeight,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.onSurface,
                  child: Stack(
                    children: [
                      // Sol üst ve sağ alt yeşil dalgalar (Görsele özel)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ForgotPasswordBlobPainter(
                            primaryColor: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      // Form İçeriği
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(flex: 3),
                            Text(
                              'Forgot Password',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Enter your email to reset your password.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Email Input Box
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary
                                        .withValues(alpha: 0.08),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.mail_outline,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        fontSize: 15,
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary
                                              .withValues(alpha: 0.5),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            // SEND Butonu
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  if (!_isLoading) _handleResetPassword();
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.onPrimary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: _isLoading
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(width: 10),
                                            CircularProgressIndicator(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              strokeWidth: 4,
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'SEND',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const Spacer(flex: 3),
                            // Back to Login Link
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.push(AppRoutes.login);
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Back to ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                      ),
                                    ),
                                    Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
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

/// Görseldeki sol üst geniş dairesel dalga ve sağ alt köşe yuvarlağını çizen CustomPainter[cite: 3]
class _ForgotPasswordBlobPainter extends CustomPainter {
  final Color primaryColor;

  _ForgotPasswordBlobPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // Sol üst yeşil dairesel kıvrım[cite: 3]
    final topLeftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.62, 0)
      ..cubicTo(w * 0.60, h * 0.08, w * 0.35, h * 0.18, w * 0.18, h * 0.18)
      ..cubicTo(w * 0.08, h * 0.18, 0, h * 0.12, 0, h * 0.08)
      ..close();
    canvas.drawPath(topLeftPath, paint);

    // Sağ alt dairesel yuvarlak[cite: 2, 3]
    final bottomRightPath = Path()
      ..moveTo(0, h * 0.84)
      ..cubicTo(0, h * 0.94, w * 0.22, h, w * 0.28, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(bottomRightPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ForgotPasswordBlobPainter old) =>
      old.primaryColor != primaryColor;
}
