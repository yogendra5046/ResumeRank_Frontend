import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';
import '../models/analysis_history.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<AnalysisHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _history = HistoryService.getAllHistory();
  }

  // ---------- derived stats ----------
  int get _totalScans => _history.length;
  double get _avgScore => _history.isEmpty
      ? 0
      : _history.map((h) => h.score).reduce((a, b) => a + b) / _history.length;
  int get _bestScore =>
      _history.isEmpty ? 0 : _history.map((h) => h.score).reduce((a, b) => a > b ? a : b);
  int get _improvement {
    if (_history.length < 2) return 0;
    final sorted = [..._history]..sort((a, b) => a.date.compareTo(b.date));
    return sorted.last.score - sorted.first.score;
  }

  List<FlSpot> get _scoreSpots {
    final sorted = [..._history]..sort((a, b) => a.date.compareTo(b.date));
    return sorted
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.score.toDouble()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Progress Dashboard',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _history = HistoryService.getAllHistory()),
          ),
        ],
      ),
      body: _history.isEmpty ? _buildEmptyState() : _buildDashboard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined_rounded,
              size: 80, color: AppColors.primary),
          SizedBox(height: 24),
          Text('No Scan History Yet',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
          SizedBox(height: 8),
          Text('Scan your first resume to see your progress here.',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 14)),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            icon: Icon(Icons.upload_file_rounded),
            label: Text('Scan a Resume'),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- KPI Row ---
          Row(
            children: [
              Expanded(child: _buildKpiCard('Total Scans', '$_totalScans',
                  Icons.document_scanner_rounded, AppColors.primary)),
              SizedBox(width: 12),
              Expanded(child: _buildKpiCard('Best Score', '$_bestScore%',
                  Icons.emoji_events_rounded, AppColors.warning)),
              SizedBox(width: 12),
              Expanded(child: _buildKpiCard(
                  'Improvement',
                  _improvement >= 0 ? '+$_improvement%' : '$_improvement%',
                  Icons.trending_up_rounded,
                  _improvement >= 0 ? AppColors.success : AppColors.error)),
            ],
          ).animate().fadeIn().slideY(begin: -0.1),

          SizedBox(height: 28),

          // --- Score Trend Chart ---
          if (_scoreSpots.length > 1) ...[
            Text('ATS Score Trend',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 12),
            PremiumCard(
              height: 200,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 20, 16, 8),
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 100,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _scoreSpots,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        dotData: FlDotData(
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: 28),
          ],

          // --- Avg score ---
          PremiumCard(
            accentColor: AppColors.primary,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${_avgScore.toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Average ATS Score',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 4),
                      Text(
                        _avgScore >= 70
                            ? 'Great! You are consistently scoring above average.'
                            : 'Focus on adding missing keywords to improve your score.',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),

          SizedBox(height: 28),

          // --- Recent Activity ---
          Text('Recent Scans',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface)),
          SizedBox(height: 12),
          ..._history.take(5).map((h) => _buildHistoryTile(h)),

          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
      String label, String value, IconData icon, Color color) {
    return PremiumCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color)),
          SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(AnalysisHistory h) {
    final scoreColor = h.score >= 70
        ? AppColors.success
        : (h.score >= 50 ? AppColors.warning : AppColors.error);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text('${h.score}%',
                  style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 13)),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(height: 2),
                Text(DateFormat('MMM d, yyyy').format(h.date),
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}
