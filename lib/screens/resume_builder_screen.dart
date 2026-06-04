import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import 'package:glass_kit/glass_kit.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});
  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentStep = 0;

  // --- Form controllers ---
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final List<Map<String, TextEditingController>> _experiences = [];
  final List<Map<String, TextEditingController>> _education = [];
  final List<String> _skills = [];
  final _skillInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentStep = _tabController.index);
      }
    });
    _addExperience();
    _addEducation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addExperience() {
    _experiences.add({
      'title': TextEditingController(),
      'company': TextEditingController(),
      'duration': TextEditingController(),
      'bullets': TextEditingController(),
    });
    setState(() {});
  }

  void _addEducation() {
    _education.add({
      'degree': TextEditingController(),
      'institution': TextEditingController(),
      'year': TextEditingController(),
      'gpa': TextEditingController(),
    });
    setState(() {});
  }

  void _addSkill() {
    final s = _skillInput.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) {
      setState(() {
        _skills.add(s);
        _skillInput.clear();
      });
    }
  }

  String _buildMarkdownResume() {
    final sb = StringBuffer();
    // Contact
    sb.writeln('# ${_nameCtrl.text}');
    if (_emailCtrl.text.isNotEmpty) sb.writeln('📧 ${_emailCtrl.text}');
    if (_phoneCtrl.text.isNotEmpty) sb.writeln('📞 ${_phoneCtrl.text}');
    if (_locationCtrl.text.isNotEmpty) sb.writeln('📍 ${_locationCtrl.text}');
    if (_linkedinCtrl.text.isNotEmpty) sb.writeln('🔗 ${_linkedinCtrl.text}');
    sb.writeln();

    // Summary
    if (_summaryCtrl.text.isNotEmpty) {
      sb.writeln('## Professional Summary');
      sb.writeln(_summaryCtrl.text);
      sb.writeln();
    }

    // Experience
    sb.writeln('## Work Experience');
    for (final exp in _experiences) {
      final title = exp['title']!.text;
      final company = exp['company']!.text;
      final duration = exp['duration']!.text;
      final bullets = exp['bullets']!.text;
      if (title.isEmpty && company.isEmpty) continue;
      sb.writeln('### $title at $company');
      if (duration.isNotEmpty) sb.writeln('*$duration*');
      if (bullets.isNotEmpty) {
        for (final line in bullets.split('\n')) {
          if (line.trim().isNotEmpty) sb.writeln('- $line');
        }
      }
      sb.writeln();
    }

    // Education
    sb.writeln('## Education');
    for (final edu in _education) {
      final degree = edu['degree']!.text;
      final inst = edu['institution']!.text;
      final year = edu['year']!.text;
      final gpa = edu['gpa']!.text;
      if (degree.isEmpty && inst.isEmpty) continue;
      sb.writeln('### $degree');
      sb.writeln('$inst${year.isNotEmpty ? ' | $year' : ''}${gpa.isNotEmpty ? ' | GPA: $gpa' : ''}');
      sb.writeln();
    }

    // Skills
    if (_skills.isNotEmpty) {
      sb.writeln('## Skills');
      sb.writeln(_skills.join(' • '));
    }

    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Resume Builder',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(text: 'CONTACT', icon: Icon(Icons.person_rounded, size: 16)),
            Tab(text: 'SUMMARY', icon: Icon(Icons.notes_rounded, size: 16)),
            Tab(
                text: 'EXPERIENCE',
                icon: Icon(Icons.work_rounded, size: 16)),
            Tab(
                text: 'EDUCATION',
                icon: Icon(Icons.school_rounded, size: 16)),
            Tab(
                text: 'SKILLS & PREVIEW',
                icon: Icon(Icons.preview_rounded, size: 16)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContactTab(),
          _buildSummaryTab(),
          _buildExperienceTab(),
          _buildEducationTab(),
          _buildSkillsPreviewTab(),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        _buildCoachCard(
          "Did You Know?", 
          "Recruiters spend an average of 6 seconds looking at a resume. If your contact info is hard to find or your email is unprofessional (e.g., 'skaterboy99@...'), you are instantly rejected.", 
          Icons.lightbulb_rounded
        ),
        _premiumField('Full Name', _nameCtrl, Icons.badge_rounded, 'First and Last Name'),
        _premiumField('Email Address', _emailCtrl, Icons.email_rounded, 'firstname.lastname@email.com', type: TextInputType.emailAddress),
        _premiumField('Phone Number', _phoneCtrl, Icons.phone_rounded, '+1 (555) 000-0000', type: TextInputType.phone),
        _premiumField('Location', _locationCtrl, Icons.location_on_rounded, 'City, State/Country'),
        _premiumField('LinkedIn Profile', _linkedinCtrl, Icons.link_rounded, 'linkedin.com/in/yourprofile', type: TextInputType.url),
        SizedBox(height: 24),
        _navButtons(),
      ],
    ).animate().fadeIn();
  }

  Widget _buildSummaryTab() {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        _buildCoachCard(
          "AI Coach Insight", 
          "Never write an 'Objective' statement. Modern resumes use a 'Professional Summary'. In 2-3 sentences, highlight your total years of experience, your top 2 skills, and your biggest career achievement.", 
          Icons.psychology_rounded
        ),
        SizedBox(height: 8),
        Text("Your Pitch",
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.primary)),
        SizedBox(height: 8),
        TextField(
          controller: _summaryCtrl,
          maxLines: 6,
          style: TextStyle(fontSize: 14),
          decoration: _inputDeco(Icons.notes_rounded, 'e.g. Results-driven Software Engineer with 3+ years of experience architecting scalable backend systems. Proven ability to reduce cloud costs by 30%...'),
        ),
        SizedBox(height: 24),
        _navButtons(),
      ],
    ).animate().fadeIn();
  }

  Widget _buildExperienceTab() {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        _buildCoachCard(
          "The Google Formula", 
          "Write your bullet points using Google's X-Y-Z formula: 'Accomplished [X] as measured by [Y], by doing [Z]'. Start every single bullet point with a strong Action Verb (e.g., Spearheaded, Architected, Optimized).", 
          Icons.trending_up_rounded
        ),
        ..._experiences.asMap().entries.map((entry) {
          final i = entry.key;
          final exp = entry.value;
          return PremiumCard(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Role ${i + 1}',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
                    if (_experiences.length > 1)
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () => setState(() => _experiences.removeAt(i)),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                _premiumField('Job Title', exp['title']!, Icons.work_outline_rounded, 'e.g. Senior Product Manager'),
                _premiumField('Company Name', exp['company']!, Icons.business_rounded, 'e.g. TechCorp Inc.'),
                _premiumField('Duration', exp['duration']!, Icons.date_range_rounded, 'e.g. Jan 2022 - Present'),
                SizedBox(height: 8),
                Text("Achievements (One per line)",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.primary)),
                SizedBox(height: 6),
                TextField(
                  controller: exp['bullets'],
                  maxLines: 5,
                  style: TextStyle(fontSize: 13, height: 1.5),
                  decoration: _inputDeco(Icons.format_list_bulleted_rounded,
                      '• Spearheaded the migration of legacy systems...\n• Increased user retention by 25% through...'),
                ),
              ],
            ),
          );
        }),
        Container(
          height: 60,
          margin: EdgeInsets.only(bottom: 24),
          child: OutlinedButton.icon(
            onPressed: _addExperience,
            icon: Icon(Icons.add_circle_rounded),
            label: Text('ADD ROLE', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        _navButtons(),
      ],
    ).animate().fadeIn();
  }

  Widget _buildEducationTab() {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        _buildCoachCard(
          "Education Rules", 
          "If you have a college degree, leave your high school off. If you graduated more than 10 years ago, remove the graduation year to prevent age bias. ONLY include your GPA if it is above 3.5.", 
          Icons.school_rounded
        ),
        ..._education.asMap().entries.map((entry) {
          final i = entry.key;
          final edu = entry.value;
          return PremiumCard(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Institution ${i + 1}',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
                    if (_education.length > 1)
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () => setState(() => _education.removeAt(i)),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                _premiumField('Degree / Major', edu['degree']!, Icons.menu_book_rounded, 'e.g. B.S. in Computer Science'),
                _premiumField('Institution Name', edu['institution']!, Icons.account_balance_rounded, 'e.g. University of Example'),
                Row(
                  children: [
                    Expanded(child: _premiumField('Graduation Year', edu['year']!, Icons.calendar_today_rounded, 'e.g. 2024', type: TextInputType.number)),
                    SizedBox(width: 16),
                    Expanded(child: _premiumField('GPA (Optional)', edu['gpa']!, Icons.grade_rounded, 'e.g. 3.8', type: TextInputType.number)),
                  ],
                ),
              ],
            ),
          );
        }),
        Container(
          height: 60,
          margin: EdgeInsets.only(bottom: 24),
          child: OutlinedButton.icon(
            onPressed: _addEducation,
            icon: Icon(Icons.add_circle_rounded),
            label: Text('ADD EDUCATION', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        _navButtons(),
      ],
    ).animate().fadeIn();
  }

  Widget _buildSkillsPreviewTab() {
    final markdown = _buildMarkdownResume();
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        _buildCoachCard(
          "ATS Compatibility", 
          "Add 8-12 hard skills. Do not list basic skills like 'Microsoft Word'. When you copy the markdown below, paste it into a plain template. Do not use multi-column layouts or graphics, as ATS parsers fail to read them.", 
          Icons.memory_rounded
        ),
        // Skills input
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Core Competencies',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillInput,
                      onSubmitted: (_) => _addSkill(),
                      decoration: _inputDeco(
                          Icons.add_circle_outline_rounded, 'Type a skill (e.g. Python, Agile) & press Enter'),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addSkill, 
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('ADD'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills
                    .map((s) => Chip(
                          label: Text(s,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          backgroundColor: AppColors.primary,
                          deleteIconColor: Colors.white70,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          onDeleted: () => setState(() => _skills.remove(s)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: 32),

        // Preview card
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ATS-Ready Markdown',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface)),
            ElevatedButton.icon(
              icon: Icon(Icons.copy_rounded, size: 16),
              label: Text("COPY TO CLIPBOARD"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: markdown));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Resume copied to clipboard! Paste into Word or Google Docs.')));
              },
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white, // Resembles paper
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 2)
            ],
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SelectableText(
            markdown.isEmpty ? 'Fill in your details to generate the document...' : markdown,
            style: GoogleFonts.ptSerif(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 24),
        _navButtons(),
        SizedBox(height: 40),
      ],
    ).animate().fadeIn();
  }

  Widget _buildCoachCard(String title, String fact, IconData icon) {
    return GlassContainer.clearGlass(
      height: 140, // Reduced from expanded to fixed height for better layout
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      blur: 15,
      borderWidth: 1,
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.1),
          AppColors.primary.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900, 
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      fact,
                      style: TextStyle(fontSize: 12, height: 1.5, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumField(String label, TextEditingController ctrl, IconData icon, String hint,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AppColors.primary)),
          SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: type,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: _inputDeco(icon, hint),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(IconData icon, String hint) => InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        hintText: hint,
        hintStyle:
            TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 13),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      );

  Widget _navButtons() => Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_currentStep > 0) {
                      _tabController.animateTo(_currentStep - 1);
                    }
                  },
                  icon: Icon(Icons.arrow_back_rounded),
                  label: Text('Previous',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_currentStep == 0 && _nameCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please enter at least your Full Name to continue.')));
                    return;
                  }
                  
                  if (_currentStep < 4) {
                    _tabController.animateTo(_currentStep + 1);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Don\'t forget to copy your resume above!')));
                  }
                },
                icon: Icon(_currentStep < 4 ? Icons.arrow_forward_rounded : Icons.check_circle_rounded),
                label: Text(_currentStep < 4 ? 'Next Step' : 'Done',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      );
}
