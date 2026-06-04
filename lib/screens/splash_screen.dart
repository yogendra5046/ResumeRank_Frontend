import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _minDelayReached = false;
  AuthState? _pendingState;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _minDelayReached = true);
        if (_pendingState != null) {
          _handleNavigation(_pendingState!);
        } else {
          final currentState = context.read<AuthCubit>().state;
          if (currentState is Authenticated || currentState is Unauthenticated) {
            _handleNavigation(currentState);
          }
        }
      }
    });
  }

  void _handleNavigation(AuthState state) {
    if (state is Authenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (state is Unauthenticated) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (_minDelayReached) {
          _handleNavigation(state);
        } else {
          _pendingState = state;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Background Gradient Glow
            Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 1.seconds)
                .scale(begin: const Offset(0.5, 0.5)),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/app_icon.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(delay: 200.ms, curve: Curves.easeOutBack)
                      .shimmer(delay: 1200.ms, duration: 1.seconds),

                  SizedBox(height: 24),

                  Text(
                        'RESUME RANK',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 1.seconds, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),

                  SizedBox(height: 8),

                  Text(
                    'Rank Up Your Resume. Land The Job.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 1.5.seconds),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
