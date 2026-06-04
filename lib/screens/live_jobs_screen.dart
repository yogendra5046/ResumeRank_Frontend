import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../services/resume_storage_service.dart';
import '../features/analysis/presentation/bloc/analysis_cubit.dart';
import '../features/analysis/presentation/pages/dashboard_page.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../features/history/presentation/bloc/history_cubit.dart';
import '../features/analysis/data/models/analysis_result_model.dart';

class LiveJobsScreen extends StatefulWidget {
  final String? initialQuery;
  const LiveJobsScreen({super.key, this.initialQuery});
  @override
  State<LiveJobsScreen> createState() => _LiveJobsScreenState();
}

class _LiveJobsScreenState extends State<LiveJobsScreen> {
  final _searchCtrl = TextEditingController();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://resumerankappbackend-production.up.railway.app/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  List<dynamic> _jobs = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _selectedCountry = 'in';
  String? _source;

  final Map<String, String> _countries = {
    'in': '🇮🇳 India',
    'us': '🇺🇸 USA',
    'gb': '🇬🇧 UK',
    'au': '🇦🇺 Australia',
    'ca': '🇨🇦 Canada',
  };

  @override
  void initState() {
    super.initState();
    String? startingQuery = widget.initialQuery;
    
    if (startingQuery == null) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        final bio = authState.user.bio;
        if (bio.isNotEmpty) {
          startingQuery = bio.split('\n').first;
        }
      }
    }

    if (startingQuery != null && startingQuery.isNotEmpty) {
      _searchCtrl.text = startingQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _jobs = [];
    });
    try {
      final resp = await _dio.get('/insights/jobs',
          queryParameters: {'query': q, 'country': _selectedCountry, 'results': 10});
      setState(() {
        _jobs = resp.data['jobs'] ?? [];
        _source = resp.data['source'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnalysisCubit, AnalysisState>(
      listener: (context, state) {
        if (state is AnalysisLoading) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analyzing Fit...'), duration: Duration(seconds: 2)));
        } else if (state is AnalysisSuccess) {
              final file = ResumeStorageService().activeResume;
              if (file != null) {
                context.read<HistoryCubit>().saveAnalysisResult(
                  fileName: file.name,
                  score: state.result.score,
                  percentile: state.result.percentile,
                  missingKeywords: state.result.missingKeywords,
                  suggestions: state.result.suggestions,
                  rawJson: jsonEncode((state.result as AnalysisResultModel).toJson()),
                );
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardPage(result: state.result),
                ),
              );
        } else if (state is AnalysisError) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Live Job Search',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        ),
        body: Column(
        children: [
          // --- Search bar ---
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onSubmitted: (_) => _search(),
                        decoration: InputDecoration(
                          hintText: 'Search jobs (e.g. Flutter, Data Analyst...)',
                          hintStyle: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: AppColors.primary),
                          filled: true,
                          fillColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _search,
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14)),
                      child: _isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text('Search'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Country selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _countries.entries.map((e) {
                      final selected = _selectedCountry == e.key;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(e.value,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: selected
                                      ? Colors.white
                                      : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedCountry = e.key),
                          selectedColor: AppColors.primary,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          side: BorderSide(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.2)),
                          checkmarkColor: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // --- Results ---
          Expanded(
            child: !_hasSearched
                ? _buildInitialState()
                : _isLoading
                    ? _buildLoadingState()
                    : _jobs.isEmpty
                        ? _buildEmptyState()
                        : _buildResults(),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.manage_search_rounded,
                size: 56, color: AppColors.primary),
          ),
          SizedBox(height: 24),
          Text('Find Your Next Role',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            'Search across thousands of live job listings\nmatched to your skills.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (_, i) => Container(
        margin: EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
      ).animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.2)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 64, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
          SizedBox(height: 16),
          Text('No jobs found',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Try a different keyword or country.',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B))),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildResults() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        if (_source == 'mock')
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.warning, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo data shown. Set ADZUNA_APP_ID & ADZUNA_APP_KEY for live listings.',
                    style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),
        ..._jobs.asMap().entries.map((entry) {
          final i = entry.key;
          final job = entry.value;
          return _buildJobCard(job, i);
        }),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildJobCard(dynamic job, int index) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.business_rounded,
                    color: AppColors.primary, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['title'] ?? '',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 2),
                    Text(job['company'] ?? '',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _tag(Icons.location_on_rounded, job['location'] ?? ''),
              _tag(Icons.payments_rounded, job['salary'] ?? 'Not disclosed'),
              if (job['posted'] != null && job['posted'].toString().isNotEmpty)
                _tag(Icons.access_time_rounded, job['posted']),
            ],
          ),
          if (job['description'] != null &&
              job['description'].toString().isNotEmpty) ...[
            SizedBox(height: 12),
            Text(job['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.5)),
          ],
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (job['description'] == null || job['description'].toString().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No job description available to analyze')));
                      return;
                    }
                    if (!ResumeStorageService().hasResume) {
                       final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                       if (result != null && result.files.isNotEmpty) {
                         ResumeStorageService().setResume(result.files.first);
                       } else {
                         return;
                       }
                    }
                    if (!context.mounted) return;
                    
                    // Combine title, company, and description to give the AI maximum context
                    // especially since API descriptions can sometimes be truncated. We append
                    // the URL so the backend can automatically scrape the full JD.
                    final fullJdContext = "Job Title: ${job['title']}\nCompany: ${job['company']}\n\nDescription:\n${job['description']}\n\nURL: ${job['url']}";
                    
                    context.read<AnalysisCubit>().analyzeResume(
                      resumeFile: ResumeStorageService().activeResume!,
                      jdText: fullJdContext,
                    );
                  },
                  icon: Icon(Icons.analytics_rounded, size: 16),
                  label: Text('Analyze Fit', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = job['url'] ?? '';
                    if (url.isNotEmpty) {
                      await launchUrlString(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text('Apply', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80)).slideY(begin: 0.1);
  }

  Widget _tag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
        SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 11)),
      ],
    );
  }
}
