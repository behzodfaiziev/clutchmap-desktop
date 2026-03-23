import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.backgroundDark,
        child: Stack(
          children: [
            _buildBackgroundDecorations(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 448),
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildAuthCard(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Positioned.fill(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Stack(
          children: [
            // Radial gradients
            Positioned(
              left: MediaQuery.sizeOf(context).width * 0.2 - 80,
              top: MediaQuery.sizeOf(context).height * 0.3 - 80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.05),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.sizeOf(context).width * 0.8 - 80,
              top: MediaQuery.sizeOf(context).height * 0.7 - 80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.05),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Tactical lines
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.25,
              left: -MediaQuery.sizeOf(context).width * 0.25,
              child: Transform.rotate(
                angle: -15 * 3.14159 / 180,
                child: Container(
                  height: 1,
                  width: MediaQuery.sizeOf(context).width * 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.5,
              left: -MediaQuery.sizeOf(context).width * 0.33,
              child: Transform.rotate(
                angle: -15 * 3.14159 / 180,
                child: Container(
                  height: 1,
                  width: MediaQuery.sizeOf(context).width * 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.75,
              left: -MediaQuery.sizeOf(context).width * 0.25,
              child: Transform.rotate(
                angle: -15 * 3.14159 / 180,
                child: Container(
                  height: 1,
                  width: MediaQuery.sizeOf(context).width * 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Circles top-right
            Positioned(
              top: 40,
              right: 40,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 80,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.polyline,
                  size: 20,
                  color: AppColors.backgroundDark,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Clutch Map',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Pricing',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.neutralSurface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Clutch Map',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plan, create, and share FPS strategies with your team.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _buildGoogleButton(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: AppColors.neutralSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.neutralBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.neutralBorder),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: AppColors.neutralSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.neutralBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.neutralBorder),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                    LoginRequested(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state is AuthLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue with Email'),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.neutralBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'NEW TO CLUTCH?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.neutralBorder)),
              ],
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.neutralBorder),
                foregroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Create an account'),
            ),
            const SizedBox(height: 32),
            Text(
              'By continuing, you agree to our',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white38,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const Text(' and ', style: TextStyle(fontSize: 12, color: Colors.white38)),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const Text('.', style: TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _googleIcon(),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'STATUS: ONLINE',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white38,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'BUILD: v2.4.0-stable',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white38,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            '© 2024 CLUTCH MAP INC.',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white38,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 24;
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(
      Path()
        ..moveTo(22.56 * r, 12.25 * r)
        ..cubicTo(22.56 * r, 11.47 * r, 22.49 * r, 10.72 * r, 22.36 * r, 10 * r)
        ..lineTo(12 * r, 10 * r)
        ..lineTo(12 * r, 14.26 * r)
        ..lineTo(17.92 * r, 14.26 * r)
        ..cubicTo(17.66 * r, 15.63 * r, 16.88 * r, 16.79 * r, 15.71 * r, 17.57 * r)
        ..lineTo(15.71 * r, 20.34 * r)
        ..lineTo(19.28 * r, 20.34 * r)
        ..cubicTo(21.36 * r, 18.42 * r, 22.56 * r, 15.7 * r, 22.56 * r, 12.25 * r)
        ..close(),
      paint,
    );
    paint.color = const Color(0xFF34A853);
    canvas.drawPath(
      Path()
        ..moveTo(12 * r, 23 * r)
        ..cubicTo(14.97 * r, 23 * r, 17.46 * r, 22.02 * r, 19.28 * r, 20.34 * r)
        ..lineTo(15.71 * r, 17.57 * r)
        ..cubicTo(14.69 * r, 18.23 * r, 13.41 * r, 18.63 * r, 11.99 * r, 18.63 * r)
        ..cubicTo(9.13 * r, 18.63 * r, 6.7 * r, 16.7 * r, 5.84 * r, 14.1 * r)
        ..lineTo(2.18 * r, 14.1 * r)
        ..lineTo(2.18 * r, 16.94 * r)
        ..cubicTo(3.99 * r, 20.53 * r, 7.7 * r, 23 * r, 12 * r, 23 * r)
        ..close(),
      paint,
    );
    paint.color = const Color(0xFFFBBC05);
    canvas.drawPath(
      Path()
        ..moveTo(5.84 * r, 14.09 * r)
        ..cubicTo(5.62 * r, 13.43 * r, 5.49 * r, 12.73 * r, 5.49 * r, 12 * r)
        ..cubicTo(5.49 * r, 11.27 * r, 5.62 * r, 10.57 * r, 5.84 * r, 9.91 * r)
        ..lineTo(5.84 * r, 7.07 * r)
        ..lineTo(2.18 * r, 7.07 * r)
        ..cubicTo(1.43 * r, 8.55 * r, 1 * r, 10.22 * r, 1 * r, 12 * r)
        ..cubicTo(1 * r, 13.78 * r, 1.43 * r, 15.45 * r, 2.18 * r, 16.93 * r)
        ..lineTo(5.84 * r, 14.09 * r)
        ..close(),
      paint,
    );
    paint.color = const Color(0xFFEA4335);
    canvas.drawPath(
      Path()
        ..moveTo(12 * r, 5.38 * r)
        ..cubicTo(13.62 * r, 5.38 * r, 15.06 * r, 5.94 * r, 16.21 * r, 7.04 * r)
        ..lineTo(19.35 * r, 3.9 * r)
        ..cubicTo(17.45 * r, 2.09 * r, 14.97 * r, 1 * r, 12 * r, 1 * r)
        ..cubicTo(7.7 * r, 1 * r, 3.99 * r, 3.47 * r, 2.18 * r, 7.07 * r)
        ..lineTo(5.84 * r, 9.91 * r)
        ..cubicTo(6.7 * r, 7.31 * r, 9.13 * r, 5.38 * r, 12 * r, 5.38 * r)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
