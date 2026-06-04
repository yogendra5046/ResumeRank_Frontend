import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../bloc/history_cubit.dart';
import '../../domain/entities/history_item.dart';
import '../../../analysis/presentation/pages/dashboard_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            onPressed: () => _showClearDialog(context),
            tooltip: "Clear All",
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: BlocBuilder<HistoryCubit, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is HistoryLoaded) {
                      final filtered = state.history
                          .where(
                            (item) => item.fileName.toLowerCase().contains(
                              _searchQuery,
                            ),
                          )
                          .toList();

                      if (filtered.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryItem(context, filtered[index]);
                        },
                      );
                    } else if (state is HistoryError) {
                      return Center(child: Text(state.message));
                    }
                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: "Search by file name...",
          prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
        ),
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

  Widget _buildHistoryItem(BuildContext context, HistoryItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        context.read<HistoryCubit>().deleteItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Analysis removed from history")),
        );
      },
      child: Container(
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
            final result = item.toAnalysisResult();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(result: result),
              ),
            );
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
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score < 40) return Colors.redAccent;
    if (score < 75) return Colors.orangeAccent;
    return Colors.teal;
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
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
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryCubit>().clearHistory();
              Navigator.pop(context);
            },
            child: Text(
              "Clear All",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
