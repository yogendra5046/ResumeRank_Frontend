import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'services/history_service.dart';
import 'services/job_service.dart';
import 'services/interview_service.dart';
import 'features/analysis/presentation/bloc/analysis_cubit.dart';
import 'features/history/presentation/bloc/history_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/history/presentation/pages/history_page.dart';
import 'features/analysis/presentation/pages/home_page.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/help_center_screen.dart';
import 'screens/about_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/resume_builder_screen.dart';
import 'screens/live_jobs_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  await di.init();

  // Prevent red screen of death in production
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Color(0xFFF8FAFC),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_fix_high_rounded,
              color: Color(0xFF4F46E5),
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Our AI is recalibrating. Please restart the app.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  };

  // Initialize Hive
  await Hive.initFlutter();
  await HistoryService.init();
  await JobService.init();
  await InterviewService.init();

  runApp(const ResumeRankApp());
}

class ResumeRankApp extends StatelessWidget {
  const ResumeRankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => di.sl<AuthCubit>()..checkAuthStatus(),
              ),
              BlocProvider(create: (context) => di.sl<AnalysisCubit>()),
              BlocProvider(
                  create: (context) => di.sl<HistoryCubit>()..loadHistory()),
            ],
            child: MaterialApp(
              title: 'Resume Rank',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              initialRoute: '/',
              routes: {
                '/': (context) => const SplashScreen(),
                '/login': (context) => const LoginPage(),
                '/signup': (context) => const SignUpPage(),
                '/onboarding': (context) => const OnboardingScreen(),
                '/home': (context) => const MainNavigation(initialIndex: 0),
                '/history': (context) => const MainNavigation(initialIndex: 1),
                '/dashboard': (context) => const DashboardScreen(),
                '/forgot-password': (context) => const ForgotPasswordScreen(),
                '/profile': (context) => const ProfileScreen(),
                '/settings': (context) => const SettingsScreen(),
                '/help': (context) => const HelpCenterScreen(),
                '/about': (context) => const AboutScreen(),
              },
            ),
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const HomePage(),
    const HistoryPage(),
    const LiveJobsScreen(),
    const ResumeBuilderScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            _buildDesktopSidebar(),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_rounded),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_document),
              label: 'Builder',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "ResumeRank",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildSidebarItem(
                      0,
                      "Dashboard",
                      Icons.dashboard_rounded,
                      "Overview & Analytics",
                    ),
                    _buildSidebarItem(
                      1,
                      "History",
                      Icons.history_rounded,
                      "Past Scans & Reports",
                    ),
                    _buildSidebarItem(
                      2,
                      "Live Jobs",
                      Icons.work_rounded,
                      "Real-time job listings",
                    ),
                    _buildSidebarItem(
                      3,
                      "Resume Builder",
                      Icons.edit_document,
                      "Build from scratch",
                    ),
                    _buildSidebarItem(
                      4,
                      "Profile",
                      Icons.person_rounded,
                      "Settings & Preferences",
                    ),
                    Divider(indent: 16, endIndent: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/dashboard'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.insert_chart_outlined_rounded,
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), size: 22),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Progress',
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontWeight: FontWeight.w600)),
                                    Text('Score trend & analytics',
                                        style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 10)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.rocket_launch_rounded, color: Colors.white),
                            SizedBox(height: 12),
                            Text(
                              "Pro Tip",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Check out the Extra Features panel after scanning to unlock Roast Mode and more!",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebarItem(
    int index,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
