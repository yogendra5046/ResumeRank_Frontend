import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/history_service.dart';
import '../models/analysis_history.dart';
//import '../models/analysis_result.dart';

import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AnalysisHistory> _history = [];
  List<AnalysisHistory> _filteredHistory = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_filterHistory);
  }

  void _loadHistory() {
    setState(() {
      _history = HistoryService.getAllHistory();
      _filteredHistory = _history;
    });
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHistory = _history
          .where((item) => item.fileName.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text(
          "Clear History?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "This will delete all past analyses. This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Clear All",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.clearAll();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Activity History",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_rounded),
            onPressed: _clearAll,
            tooltip: "Clear All",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Search by file name...",
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredHistory.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredHistory.length,
                    itemBuilder: (context, index) {
                      final item = _filteredHistory[index];
                      return _buildHistoryItem(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.1),
          ),
          SizedBox(height: 16),
          Text(
            "No history found",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(AnalysisHistory item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        onTap: () {
          Navigator.pushNamed(context, '/dashboard');
        },
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.description_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          item.fileName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy').format(item.date),
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${item.score}%",
              style: TextStyle(
                color: _getScoreColor(item.score),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 10,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score < 40) return Colors.redAccent;
    if (score < 75) return Colors.orangeAccent;
    return Colors.teal;
  }
}
