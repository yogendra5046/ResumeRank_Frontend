import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/job_service.dart';
import '../models/job_application.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class JobTrackerScreen extends StatefulWidget {
  const JobTrackerScreen({super.key});

  @override
  State<JobTrackerScreen> createState() => _JobTrackerScreenState();
}

class _JobTrackerScreenState extends State<JobTrackerScreen> {
  List<JobApplication> _jobs = [];
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _loadJobs() {
    setState(() {
      _jobs = JobService.getAllJobs();
    });
  }

  void _addJob() {
    final companyController = TextEditingController();
    final roleController = TextEditingController();
    String status = 'Applied';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          title: Text(
            "Add Application",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(companyController, "Company"),
                _buildDialogField(roleController, "Role"),
                SizedBox(height: 16),
                DropdownButton<String>(
                  value: status,
                  dropdownColor: Color(0xFF2A2A2A),
                  style: TextStyle(color: Colors.white),
                  items: ['Applied', 'Interviewing', 'Offer', 'Rejected']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => status = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (companyController.text.trim().isEmpty || roleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Company and Role are required."), backgroundColor: Colors.redAccent));
                  return;
                }
                final job = JobApplication(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  companyName: companyController.text.trim(),
                  jobTitle: roleController.text.trim(),
                  appliedDate: DateTime.now(),
                  status: status,
                  notes: '',
                );
                await JobService.addJob(job);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadJobs();
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white38),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _filter == 'All'
        ? _jobs
        : _jobs.where((j) => j.status == _filter).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Job Tracker"),
        actions: [
          IconButton(
            onPressed: _addJob,
            icon: Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: filteredJobs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) =>
                        _buildJobCard(filteredJobs[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final statuses = ['All', 'Applied', 'Interviewing', 'Offer', 'Rejected'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: statuses
            .map(
              (s) => Padding(
                padding: EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(s),
                  selected: _filter == s,
                  onSelected: (val) => setState(() => _filter = s),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: _filter == s
                        ? AppColors.primary
                        : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    fontWeight: _filter == s
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildJobCard(JobApplication job) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          job.jobTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${job.companyName} • ${DateFormat('MMM d').format(job.appliedDate)}",
          style: TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(job.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            job.status,
            style: TextStyle(
              color: _getStatusColor(job.status),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        onLongPress: () async {
          await JobService.deleteJob(job.id);
          _loadJobs();
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Applied':
        return Colors.blue;
      case 'Interviewing':
        return Colors.orange;
      case 'Offer':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline_rounded,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.1),
          ),
          SizedBox(height: 16),
          Text(
            "No applications tracked yet.",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
