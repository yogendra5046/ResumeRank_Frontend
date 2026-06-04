import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_theme.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleSignUp() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    context.read<AuthCubit>().register(
      fullName: name,
      email: email,
      password: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created successfully!")),
          );
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: isDesktop
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
              ),
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: [
                Positioned(
                  top: 24,
                  left: 24,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                _buildMobileLayout(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF064E3B)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  right: -100,
                  child:
                      Container(
                            width: 600,
                            height: 600,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.2),
                                  blurRadius: 150,
                                ),
                              ],
                            ),
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .scale(
                            duration: 6.seconds,
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.1, 1.1),
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
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
                        SizedBox(height: 40),
                        Text(
                              "Join The\nElite Network.",
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
                            .slideX(begin: 0.1),
                        SizedBox(height: 24),
                        Text(
                              "Create your free account today and unlock tools designed to give you an unfair advantage in your job search.",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 800.ms)
                            .slideX(begin: 0.1),
                        SizedBox(height: 48),
                        Row(
                              children: [
                                _buildFeatureChip(
                                  Icons.security_rounded,
                                  "Secure & Private",
                                ),
                                SizedBox(width: 16),
                                _buildFeatureChip(
                                  Icons.insights_rounded,
                                  "Data-Driven",
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
                _buildHeader(),
                SizedBox(height: 48),
                _buildTextField(
                  "FULL NAME",
                  _nameController,
                  Icons.person_outline,
                ),
                SizedBox(height: 24),
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
                _buildSignUpButton(),
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
          "Join the Elite",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ).animate().fadeIn().slideX(begin: -0.2),
        SizedBox(height: 8),
        Text(
          "Create your professional profile today",
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

  Widget _buildSignUpButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSignUp,
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
                    "CREATE ACCOUNT",
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
}
