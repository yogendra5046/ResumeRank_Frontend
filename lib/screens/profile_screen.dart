import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/resume_export_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../models/user_profile.dart';
import '../widgets/premium_widgets.dart';
import '../services/preference_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/resume_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  final PreferenceService _prefService = PreferenceService();
  bool _isDarkMode = true;
  bool _notifications = true;
  PlatformFile? _savedResume;

  @override
  void initState() {
    super.initState();
    _initializeFromCubit();
    _loadSettings();
    _savedResume = ResumeStorageService().activeResume;
  }

  Future<void> _loadSettings() async {
    final dark = await _prefService.getDarkMode();
    final notify = await _prefService.getNotifications();
    if (mounted) {
      setState(() {
        _isDarkMode = dark;
        _notifications = notify;
      });
    }
  }

  void _initializeFromCubit() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      setState(() {
        _profile = UserProfile(
          name: authState.user.fullName,
          role: authState.user.bio.isNotEmpty
              ? authState.user.bio.split('\n').first
              : 'Senior Professional',
          bio: authState.user.bio.contains('\n')
              ? authState.user.bio.split('\n').skip(1).join('\n')
              : '',
          targetSalary: authState.user.targetSalary,
          workPreference: authState.user.workPreference,
          experience: authState.user.experience
              .map((e) => ExperienceItem.fromJson(e))
              .toList(),
          education: authState.user.education
              .map((e) => EducationItem.fromJson(e))
              .toList(),
        );
      });
    }
  }

  Future<void> _saveProfile(UserProfile profile) async {
    final combinedBio = '${profile.role}\n${profile.bio}';
    await context.read<AuthCubit>().updateProfile(
      fullName: profile.name,
      bio: combinedBio,
      targetSalary: profile.targetSalary,
      workPreference: profile.workPreference,
      experience: profile.experience.map((e) => e.toJson()).toList(),
      education: profile.education.map((e) => e.toJson()).toList(),
    );
  }

  int _calculateCompleteness() {
    if (_profile == null) return 0;
    int score = 0;
    if (_profile!.name.isNotEmpty) score += 15;
    if (_profile!.role.isNotEmpty) score += 15;
    if (_profile!.bio.isNotEmpty) score += 20;
    if (_profile!.targetSalary.isNotEmpty) score += 10;
    if (_profile!.workPreference.isNotEmpty) score += 10;
    if (_profile!.experience.isNotEmpty) score += 15;
    if (_profile!.education.isNotEmpty) score += 15;
    return score;
  }

  void _showBottomEditor({
    required String title,
    required Widget content,
    required VoidCallback onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              content,
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    onSave();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white54, fontSize: 13),
          filled: true,
          fillColor: Colors.black26,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _editBasicInfo() {
    if (_profile == null) return;
    final nameController = TextEditingController(text: _profile!.name);
    final roleController = TextEditingController(text: _profile!.role);
    final salaryController = TextEditingController(
      text: _profile!.targetSalary,
    );
    final prefController = TextEditingController(
      text: _profile!.workPreference,
    );

    _showBottomEditor(
      title: "Edit Preferences",
      content: Column(
        children: [
          _buildTextField(nameController, "Full Name"),
          _buildTextField(roleController, "Current Role"),
          _buildTextField(salaryController, "Target Salary (e.g. 15LPA)"),
          _buildTextField(prefController, "Work Preference (Remote, Hybrid)"),
        ],
      ),
      onSave: () {
        final updated = UserProfile(
          name: nameController.text,
          role: roleController.text,
          bio: _profile!.bio,
          targetSalary: salaryController.text,
          workPreference: prefController.text,
          experience: _profile!.experience,
          education: _profile!.education,
        );
        _saveProfile(updated);
      },
    );
  }

  void _editBio() {
    if (_profile == null) return;
    final bioController = TextEditingController(text: _profile!.bio);
    _showBottomEditor(
      title: "Professional Bio",
      content: _buildTextField(
        bioController,
        "Tell us about your career...",
        maxLines: 5,
      ),
      onSave: () {
        final updated = UserProfile(
          name: _profile!.name,
          role: _profile!.role,
          bio: bioController.text,
          targetSalary: _profile!.targetSalary,
          workPreference: _profile!.workPreference,
          experience: _profile!.experience,
          education: _profile!.education,
        );
        _saveProfile(updated);
      },
    );
  }

  void _addExperience() {
    final companyController = TextEditingController();
    final roleController = TextEditingController();
    final periodController = TextEditingController();
    final descController = TextEditingController();

    _showBottomEditor(
      title: "Add Experience",
      content: Column(
        children: [
          _buildTextField(companyController, "Company Name"),
          _buildTextField(roleController, "Job Title"),
          _buildTextField(periodController, "Duration (e.g. 2021 - Present)"),
          _buildTextField(descController, "Key Achievements", maxLines: 3),
        ],
      ),
      onSave: () {
        final newItem = ExperienceItem(
          company: companyController.text,
          role: roleController.text,
          period: periodController.text,
          description: descController.text,
        );
        final updated = UserProfile(
          name: _profile!.name,
          role: _profile!.role,
          bio: _profile!.bio,
          targetSalary: _profile!.targetSalary,
          workPreference: _profile!.workPreference,
          experience: [..._profile!.experience, newItem],
          education: _profile!.education,
        );
        _saveProfile(updated);
      },
    );
  }

  void _addEducation() {
    final instController = TextEditingController();
    final degreeController = TextEditingController();
    final yearController = TextEditingController();

    _showBottomEditor(
      title: "Add Education",
      content: Column(
        children: [
          _buildTextField(instController, "Institution / University"),
          _buildTextField(degreeController, "Degree (e.g. B.Tech CS)"),
          _buildTextField(
            yearController,
            "Graduation Year",
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      onSave: () {
        final newItem = EducationItem(
          institution: instController.text,
          degree: degreeController.text,
          year: yearController.text,
        );
        final updated = UserProfile(
          name: _profile!.name,
          role: _profile!.role,
          bio: _profile!.bio,
          targetSalary: _profile!.targetSalary,
          workPreference: _profile!.workPreference,
          experience: _profile!.experience,
          education: [..._profile!.education, newItem],
        );
        _saveProfile(updated);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is Authenticated) {
          _initializeFromCubit();
        }
      },
      builder: (context, state) {
        if (state is AuthLoading && _profile == null) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (_profile == null)
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: Text(
                "Profile not found",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          );

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(state),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCompletenessCard(),
                          SizedBox(height: 32),
                          _buildSectionHeader(
                            "CAREER STORY",
                            Icons.person_rounded,
                            _editBio,
                          ),
                          SizedBox(height: 16),
                          _buildBioCard(),
                          SizedBox(height: 32),
                          _buildSectionHeader(
                            "WORK EXPERIENCE",
                            Icons.business_center_rounded,
                            _addExperience,
                          ),
                          SizedBox(height: 16),
                          if (_profile!.experience.isEmpty)
                            _buildEmptyState(
                              "No experience added yet",
                              Icons.work_outline_rounded,
                              _addExperience,
                            )
                          else
                            ..._profile!.experience.map(
                              (e) => _buildExperienceCard(e),
                            ),
                          SizedBox(height: 32),
                          _buildSectionHeader(
                            "EDUCATION",
                            Icons.school_rounded,
                            _addEducation,
                          ),
                          SizedBox(height: 16),
                          if (_profile!.education.isEmpty)
                            _buildEmptyState(
                              "No education added yet",
                              Icons.menu_book_rounded,
                              _addEducation,
                            )
                          else
                            ..._profile!.education.map(
                              (e) => _buildEducationCard(e),
                            ),
                          SizedBox(height: 32),
                          _buildSectionHeader(
                            "SAVED RESUME",
                            Icons.file_present_rounded,
                            null,
                          ),
                          SizedBox(height: 16),
                          _buildResumeUploadCard(),
                          SizedBox(height: 40),
                          _buildSectionHeader(
                            "SETTINGS & SUPPORT",
                            Icons.settings_rounded,
                            null,
                          ),
                          SizedBox(height: 16),
                          _buildSwitchTile(
                            "Dark Mode",
                            Icons.dark_mode_outlined,
                            context.watch<ThemeProvider>().isDark,
                            (v) {
                              context.read<ThemeProvider>().setTheme(v);
                            },
                          ),
                          _buildSwitchTile(
                            "Notifications",
                            Icons.notifications_none_rounded,
                            _notifications,
                            (v) async {
                              await _prefService.setNotifications(v);
                              setState(() => _notifications = v);
                            },
                          ),
                          _buildActionTile(
                            "Subscription",
                            Icons.star_outline_rounded,
                            () {},
                            trailingText: "Free Plan",
                          ),
                          _buildActionTile(
                            "Language",
                            Icons.language_rounded,
                            () {},
                            trailingText: "English",
                          ),
                          _buildActionTile(
                            "Help Center",
                            Icons.help_outline_rounded,
                            () => Navigator.pushNamed(context, '/help'),
                          ),
                          _buildActionTile(
                            "Privacy Policy",
                            Icons.privacy_tip_outlined,
                            () {},
                          ),
                          _buildActionTile(
                            "About",
                            Icons.info_outline_rounded,
                            () => Navigator.pushNamed(context, '/about'),
                          ),
                          SizedBox(height: 24),
                          _buildLogoutButton(),
                          SizedBox(height: 100), // padding for bottom nav
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(AuthState state) {
    return SliverAppBar(
      expandedHeight: 340.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      actions: [
        if (state is AuthLoading)
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        IconButton(
          onPressed: () => ResumeExportService.generateAndShare(_profile!),
          icon: Icon(
            Icons.picture_as_pdf_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: "Export PDF",
        ),
        IconButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Color(0xFF1E1E1E),
                title: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  "Are you sure you want to log out of your account?",
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                    ),
                    child: Text("Logout"),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              if (!context.mounted) return;
              context.read<AuthCubit>().logout();
            }
          },
          icon: Icon(Icons.logout_rounded, color: Colors.redAccent),
          tooltip: "Logout",
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF9333EA)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade100,
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _editBasicInfo,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              SizedBox(height: 16),
              Text(
                _profile!.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 200.ms),
              SizedBox(height: 4),
              Text(
                _profile!.role,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(delay: 300.ms),
              SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildChip(_profile!.targetSalary, Icons.payments_rounded),
                  _buildChip(
                    _profile!.workPreference,
                    Icons.location_on_rounded,
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, IconData icon) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletenessCard() {
    final score = _calculateCompleteness();
    return PremiumCard(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '$score%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Profile Completeness",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  score == 100
                      ? "Your profile is fully optimized."
                      : "Complete your profile to get more accurate AI career insights.",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback? onAdd) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (onAdd != null)
          IconButton(
            onPressed: onAdd,
            icon: Icon(
              title == "CAREER STORY"
                  ? Icons.edit_rounded
                  : Icons.add_circle_outline_rounded,
              size: 22,
              color: AppColors.primary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildEmptyState(
    String message,
    IconData icon,
    VoidCallback onAction,
  ) {
    return GestureDetector(
      onTap: onAction,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tap to add",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioCard() {
    if (_profile!.bio.isEmpty)
      return _buildEmptyState(
        "No bio added yet",
        Icons.article_rounded,
        _editBio,
      );
    return PremiumCard(
      child: Text(
        _profile!.bio,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildExperienceCard(ExperienceItem item) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.corporate_fare_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.role,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      item.company,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          item.period,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (item.description.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: -8,
            top: -8,
            child: IconButton(
              onPressed: () {
                setState(() => _profile!.experience.remove(item));
                _saveProfile(_profile!);
              },
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(EducationItem item) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.teal,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.degree,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      item.institution,
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          item.year,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: -8,
            top: -8,
            child: IconButton(
              onPressed: () {
                setState(() => _profile!.education.remove(item));
                _saveProfile(_profile!);
              },
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    String? trailingText,
  }) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: trailingText != null
            ? Text(
                trailingText,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              )
            : Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        color: Colors.redAccent.withValues(alpha: 0.05),
      ),
      child: TextButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Color(0xFF1E1E1E),
              title: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                "Are you sure you want to log out of your account?",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                  ),
                  child: Text("Logout"),
                ),
              ],
            ),
          );

          if (confirm == true) {
            if (!mounted) return;
            context.read<AuthCubit>().logout();
          }
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          "Log Out",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildResumeUploadCard() {
    return PremiumCard(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _savedResume != null ? _savedResume!.name : "No Resume Uploaded",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _savedResume != null ? "Used for '1-Click Match' & Fit Analysis" : "Upload to enable Instant Match",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null && result.files.isNotEmpty) {
                    ResumeStorageService().setResume(result.files.first);
                    setState(() {
                      _savedResume = result.files.first;
                    });
                  }
                },
                icon: Icon(_savedResume != null ? Icons.edit_rounded : Icons.upload_rounded, color: AppColors.primary),
              )
            ],
          )
        ],
      )
    );
  }
}

