import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_theme.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    context.read<AuthCubit>().login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -150,
                  left: -150,
                  child:
                      Container(
                            width: 500,
                            height: 500,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.15),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 120,
                                ),
                              ],
                            ),
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .scale(
                            duration: 4.seconds,
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                          ),
                ),
                Positioned(
                  bottom: -100,
                  right: -100,
                  child:
                      Container(
                            width: 400,
                            height: 400,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(
                                0xFFEC4899,
                              ).withValues(alpha: 0.15),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    0xFFEC4899,
                                  ).withValues(alpha: 0.2),
                                  blurRadius: 100,
                                ),
                              ],
                            ),
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .slide(
                            duration: 5.seconds,
                            begin: const Offset(0, 0.2),
                            end: const Offset(0.2, 0),
                          ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
                        SizedBox(height: 40),
                        Text(
                              "Supercharge\nYour Career.",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 800.ms)
                            .slideX(begin: -0.1),
                        SizedBox(height: 24),
                        Text(
                              "Join thousands of professionals landing their dream jobs using AI-powered resume analysis, ATS X-Ray vision, and custom Roadmaps.",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 800.ms)
                            .slideX(begin: -0.1),
                        SizedBox(height: 48),
                        Row(
                              children: [
                                _buildFeatureChip(
                                  Icons.auto_awesome_rounded,
                                  "AI Optimized",
                                ),
                                SizedBox(width: 16),
                                _buildFeatureChip(
                                  Icons.fact_check_rounded,
                                  "ATS Approved",
                                ),
                                SizedBox(width: 16),
                                _buildFeatureChip(
                                  Icons.speed_rounded,
                                  "Fast Results",
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 800.ms)
                            .slideY(begin: 0.2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: _buildMobileLayout(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                _buildHeader(),
                SizedBox(height: 48),
                _buildTextField(
                  "EMAIL",
                  _emailController,
                  Icons.email_outlined,
                ),
                SizedBox(height: 24),
                _buildTextField(
                  "PASSWORD",
                  _passwordController,
                  Icons.lock_outline,
                  isPassword: true,
                ),
                SizedBox(height: 48),
                _buildLoginButton(),
                SizedBox(height: 24),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ).animate().fadeIn().slideX(begin: -0.2),
        SizedBox(height: 8),
        Text(
          "Sign in to your professional account",
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 14),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade300,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    "SIGN IN",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8));
      },
    );
  }

  Widget _buildSignUpLink() {
    return Column(
      children: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 14),
                children: [
                  TextSpan(text: "Don't have an account? "),
                  TextSpan(
                    text: "Sign Up",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/forgot-password'),
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
