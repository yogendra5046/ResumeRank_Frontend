import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../services/preference_service.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/auth/presentation/bloc/auth_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferenceService _prefService = PreferenceService();
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notify = await _prefService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = notify;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Settings",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            _buildSection("ACCOUNT"),
            _buildListTile(
              "Profile Details",
              Icons.person_outline_rounded,
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            _buildListTile(
              "Subscription",
              Icons.star_outline_rounded,
              trailing: "Free Plan",
            ),

            SizedBox(height: 32),
            _buildSection("PREFERENCES"),
            _buildListTile(
              "Dark Mode",
              Icons.dark_mode_outlined,
              isSwitch: true,
              switchValue: context.watch<ThemeProvider>().isDark,
              onChanged: (v) {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
            _buildListTile(
              "Notifications",
              Icons.notifications_none_rounded,
              isSwitch: true,
              switchValue: _notifications,
              onChanged: (v) async {
                await _prefService.setNotifications(v);
                setState(() => _notifications = v);
              },
            ),
            _buildListTile(
              "Language",
              Icons.language_rounded,
              trailing: "English",
            ),

            SizedBox(height: 32),
            _buildSection("SUPPORT"),
            _buildListTile("Help Center", Icons.help_outline_rounded),
            _buildListTile("Privacy Policy", Icons.privacy_tip_outlined),
            _buildListTile("About ResumeAI", Icons.info_outline_rounded),

            SizedBox(height: 48),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                ),
              ),
              child: TextButton(
                onPressed: () => _showLogoutDialog(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Log Out",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: Text(
                "Version 1.1.0 (Production)",
                style: GoogleFonts.plusJakartaSans(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.3),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Logout",
          style: GoogleFonts.plusJakartaSans(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          "Are you sure you want to end your session?",
          style: GoogleFonts.plusJakartaSans(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
        ),
        actionsPadding: EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.plusJakartaSans(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              "Logout",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon, {
    String? trailing,
    bool isSwitch = false,
    bool? switchValue,
    ValueChanged<bool>? onChanged,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: isSwitch
            ? Switch(
                value: switchValue ?? false,
                onChanged: onChanged,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.2),
              )
            : (trailing != null
                  ? Text(
                      trailing,
                      style: GoogleFonts.plusJakartaSans(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      size: 16,
                    )),
      ),
    );
  }
}
