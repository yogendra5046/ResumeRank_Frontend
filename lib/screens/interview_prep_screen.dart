import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../services/interview_service.dart';
import '../models/interview_story.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class InterviewPrepScreen extends StatefulWidget {
  const InterviewPrepScreen({super.key});

  @override
  State<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends State<InterviewPrepScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<InterviewStory> _stories = [];

  // STAR Coach Sandbox variables
  final List<String> _commonQuestions = [
    "Tell me about a time you overcame a major technical challenge.",
    "Describe a situation where you had to work with a difficult team member.",
    "Tell me about a project you led and what the outcome was.",
    "What is your greatest achievement and how did you accomplish it?",
    "Describe a time you failed and what you learned from it.",
  ];
  late String _selectedQuestion;
  final _sandboxSController = TextEditingController();
  final _sandboxTController = TextEditingController();
  final _sandboxAController = TextEditingController();
  final _sandboxRController = TextEditingController();

  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedQuestion = _commonQuestions.first;
    _loadStories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sandboxSController.dispose();
    _sandboxTController.dispose();
    _sandboxAController.dispose();
    _sandboxRController.dispose();
    super.dispose();
  }

  void _loadStories() {
    setState(() {
      _stories = InterviewService.getAllStories();
    });
  }

  // Analyze the sandbox inputs and evaluate STAR completeness
  void _analyzeStory() {
    final s = _sandboxSController.text.trim();
    final t = _sandboxTController.text.trim();
    final a = _sandboxAController.text.trim();
    final r = _sandboxRController.text.trim();

    if (s.isEmpty || t.isEmpty || a.isEmpty || r.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write text for all STAR sections to evaluate.'),
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    Future.delayed(1500.ms, () {
      // Rule-based diagnostic check
      final sScore = s.length > 30 ? 25 : 15;
      final tScore = t.length > 30 ? 25 : 15;

      // Action verbs check
      final hasVerbs = RegExp(
        r'\b(managed|built|designed|implemented|refactored|optimized|created|solved|developed)\b',
        caseSensitive: false,
      ).hasMatch(a);
      final aScore = hasVerbs ? 25 : 15;

      // Metrics check (contain numbers or %)
      final hasMetrics = RegExp(r'\b\d+%?\b').hasMatch(r);
      final rScore = hasMetrics ? 25 : 10;

      final totalScore = sScore + tScore + aScore + rScore;

      // Suggest improvements
      final improvements = <String>[];
      if (sScore < 25)
        improvements.add(
          "Expand the Situation: Provide more context about the team and timeline.",
        );
      if (tScore < 25)
        improvements.add(
          "Clarify the Task: What were the specific constraints or goals?",
        );
      if (!hasVerbs)
        improvements.add(
          "Stronger Actions: Start sentences with action verbs (e.g., Optimized, Designed) rather than passive details.",
        );
      if (!hasMetrics)
        improvements.add(
          "Quantify Results: Include numbers, percentage gains, or time saved to prove impact.",
        );

      // Compiled output
      final premiumDraft =
          'Situation:\n$s\n\n'
          'Task:\n$t\n\n'
          'Action:\n$a\n\n'
          'Result:\n$r';

      if (mounted) {
        setState(() {
          _analysisResult = {
            'score': totalScore,
            's_status': sScore == 25 ? 'Complete' : 'Needs Detail',
            't_status': tScore == 25 ? 'Complete' : 'Needs Detail',
            'a_status': hasVerbs ? 'Strong Actions' : 'Weak Verbs',
            'r_status': hasMetrics ? 'Quantified Impact' : 'No Metrics',
            'improvements': improvements,
            'premium_draft': premiumDraft,
          };
          _isAnalyzing = false;
        });
      }
    });
  }

  void _saveSandboxAsStory() async {
    if (_analysisResult == null) return;

    final newStory = InterviewStory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _selectedQuestion.length > 35
          ? '${_selectedQuestion.substring(0, 32)}...'
          : _selectedQuestion,
      situation: _sandboxSController.text,
      task: _sandboxTController.text,
      action: _sandboxAController.text,
      result: _sandboxRController.text,
      lastModified: DateTime.now(),
    );

    await InterviewService.saveStory(newStory);
    _loadStories();

    _sandboxSController.clear();
    _sandboxTController.clear();
    _sandboxAController.clear();
    _sandboxRController.clear();
    setState(() {
      _analysisResult = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story saved to your Story Bank!')),
    );
    _tabController.animateTo(0);
  }

  void _editStory([InterviewStory? story]) {
    final titleController = TextEditingController(text: story?.title);
    final sController = TextEditingController(text: story?.situation);
    final tController = TextEditingController(text: story?.task);
    final aController = TextEditingController(text: story?.action);
    final rController = TextEditingController(text: story?.result);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                story == null ? "New STAR Story" : "Edit Story",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 24),
              _buildStoryField(
                titleController,
                "Question / Theme (e.g., Conflict Resolution)",
              ),
              SizedBox(height: 16),
              _buildStoryField(
                sController,
                "Situation",
                maxLines: 3,
                hint: "Set the scene...",
              ),
              _buildStoryField(
                tController,
                "Task",
                maxLines: 2,
                hint: "What was the challenge?",
              ),
              _buildStoryField(
                aController,
                "Action",
                maxLines: 4,
                hint: "What did YOU specifically do?",
              ),
              _buildStoryField(
                rController,
                "Result",
                maxLines: 3,
                hint: "What was the outcome?",
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newStory = InterviewStory(
                      id:
                          story?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      situation: sController.text,
                      task: tController.text,
                      action: aController.text,
                      result: rController.text,
                      lastModified: DateTime.now(),
                    );
                    await InterviewService.saveStory(newStory);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _loadStories();
                  },
                  child: Text("Save Story"),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade500,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black26
                  : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("STAR Interview Coach"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: "STORY BANK", icon: Icon(Icons.folder_shared_rounded)),
            Tab(text: "STAR COACH", icon: Icon(Icons.psychology_rounded)),
            Tab(text: "GUIDEBOOK", icon: Icon(Icons.menu_book_rounded)),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _editStory(),
              icon: Icon(Icons.add),
              label: Text("Add Story"),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [_buildStoryBankTab(), _buildCoachTab(), _buildGuideTab()],
      ),
    );
  }

  Widget _buildStoryBankTab() {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const FeatureExplanationBanner(
          title: "Personal Story Bank",
          description: "Behavioral interviews require concrete examples. Store and manage your best career stories here. Having 3-5 versatile stories ready will help you answer almost any 'Tell me about a time...' question confidently.",
          icon: Icons.folder_shared_rounded,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "YOUR STORY BANK",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              ),
            ),
            if (_stories.isNotEmpty)
              Text(
                "${_stories.length} Stories",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        if (_stories.isEmpty)
          _buildEmptyStoryState()
        else
          ..._stories.map((story) => _buildStoryCard(story)),
      ],
    ).animate().fadeIn();
  }

  Widget _buildCoachTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FeatureExplanationBanner(
            title: "STAR Coach Sandbox",
            description: "Practice answering common interview questions using the STAR framework. Use this sandbox to draft your responses and check them against basic structure guidelines (Action verbs, Metrics, Completeness) to build a solid foundation.",
            icon: Icons.psychology_rounded,
          ),
          PremiumCard(
            color: AppColors.primary.withValues(alpha: 0.05),
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Draft your responses below. The sandbox will run a quick format check for action verbs and metrics, and provide a compiled draft for your story bank.',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'CHOOSE INTERVIEW QUESTION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black26
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.grey.shade300,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedQuestion,
                isExpanded: true,
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                items: _commonQuestions
                    .map(
                      (q) => DropdownMenuItem(
                        value: q,
                        child: Text(
                          q,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedQuestion = val);
                },
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildStoryField(
            _sandboxSController,
            "Situation",
            hint:
                "Set the scene. What team were you in and what was happening?",
            maxLines: 2,
          ),
          _buildStoryField(
            _sandboxTController,
            "Task",
            hint: "Explain the goal. What was the exact constraint or problem?",
            maxLines: 2,
          ),
          _buildStoryField(
            _sandboxAController,
            "Action",
            hint: "What did YOU specifically do? Use strong action verbs.",
            maxLines: 3,
          ),
          _buildStoryField(
            _sandboxRController,
            "Result",
            hint:
                "Highlight the metrics. Use numbers, percentages, or milestones.",
            maxLines: 2,
          ),
          SizedBox(height: 24),
          if (_isAnalyzing)
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    "Evaluating your STAR format...",
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ).animate().fadeIn(),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _analyzeStory,
                icon: Icon(Icons.analytics_rounded),
                label: Text('Analyze & Rate Answer'),
              ),
            ),
          SizedBox(height: 32),
          if (_analysisResult != null) _buildAnalysisResultsCard(),
          SizedBox(height: 40),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildAnalysisResultsCard() {
    final r = _analysisResult!;
    final score = r['score'] as int;
    final improvements = r['improvements'] as List<String>;
    final draft = r['premium_draft'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 32, color: AppColors.primary.withValues(alpha: 0.1)),
        Text(
          'STAR COACH DIAGNOSTICS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 16),
        PremiumCard(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completeness Score',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '$score%',
                    style: TextStyle(
                      color: score > 70 ? AppColors.success : Colors.redAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Divider(
                height: 24,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              _buildStatusRow('Situation Detail', r['s_status']),
              _buildStatusRow('Task Specification', r['t_status']),
              _buildStatusRow('Action Verb Strength', r['a_status']),
              _buildStatusRow('Result Metrics Check', r['r_status']),
            ],
          ),
        ),
        if (improvements.isNotEmpty) ...[
          SizedBox(height: 24),
          Text(
            'IMPROVEMENT TASKS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.orangeAccent,
            ),
          ),
          SizedBox(height: 12),
          ...improvements.map(
            (imp) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_right_rounded,
                    color: Colors.orangeAccent,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      imp,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COMPILED STORY DRAFT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              ),
            ),
            IconButton(
              icon: Icon(Icons.save_rounded, color: AppColors.primary),
              onPressed: _saveSandboxAsStory,
              tooltip: 'Save to Story Bank',
            ),
          ],
        ),
        SizedBox(height: 12),
        PremiumCard(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                draft,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Divider(
                height: 24,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.copy_rounded, size: 16),
                    label: Text('Copy Draft'),
                    onPressed: () {
                      importText(draft);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  void importText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Draft copied to clipboard!')));
  }

  Widget _buildStatusRow(String label, String value) {
    final complete =
        value == 'Complete' ||
        value == 'Strong Actions' ||
        value == 'Quantified Impact';
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            complete ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: complete ? AppColors.success : Colors.orangeAccent,
            size: 16,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: complete ? AppColors.success : Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(InterviewStory story) {
    final isSample = story.id.startsWith('sample');
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 16),
      accentColor: isSample ? Colors.orangeAccent : null,
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                story.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSample)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "SAMPLE",
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          "STAR Method Prep",
          style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
        ),
        childrenPadding: EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        trailing: isSample
            ? Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: Colors.grey,
              )
            : IconButton(
                onPressed: () => _editStory(story),
                icon: Icon(Icons.edit_outlined, size: 20),
              ),
        children: [
          _buildStorySection("S", story.situation),
          _buildStorySection("T", story.task),
          _buildStorySection("A", story.action),
          _buildStorySection("R", story.result),
          if (!isSample) ...[
            SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                await InterviewService.deleteStory(story.id);
                _loadStories();
              },
              icon: Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 16,
              ),
              label: Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStorySection(String letter, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primary,
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStoryState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Prepare your STAR stories here.",
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FeatureExplanationBanner(
            title: "STAR Framework Guide",
            description: "Top companies like Amazon and Google mandate the STAR format. Review these principles to understand exactly what recruiters are listening for in a successful behavioral response.",
            icon: Icons.menu_book_rounded,
          ),
          PremiumCard(
            color: AppColors.primary.withValues(alpha: 0.05),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "What is the STAR Method?",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  "The STAR method is a structured way to answer behavioral interview questions by discussing the specific Situation, Task, Action, and Result of the situation you are describing.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                _buildGuideStep(
                  "S",
                  "SITUATION",
                  "Describe the context and background.",
                ),
                _buildGuideStep(
                  "T",
                  "TASK",
                  "Explain the challenge or goal you faced.",
                ),
                _buildGuideStep(
                  "A",
                  "ACTION",
                  "Detail the specific steps YOU took.",
                ),
                _buildGuideStep(
                  "R",
                  "RESULT",
                  "Highlight the outcome and impact.",
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildGuideStep(String letter, String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: desc,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
