import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Help Center", style: GoogleFonts.plusJakartaSans()),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: EdgeInsets.all(24),
            children: [
              _buildSearchBox(context),
              SizedBox(height: 32),
              Text(
                "Frequently Asked",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 16),
              _buildFaqItem(context,
                "How is the ATS score calculated?",
                "Our AI parses your resume and compares it against 50,000+ industry-specific keywords and weighting patterns.",
              ),
              _buildFaqItem(context,
                "Why is my score lower than expected?",
                "Ensure you've pasted a specific job description. Generic resumes always score lower than tailored ones.",
              ),
              _buildFaqItem(context,
                "Is my data secure?",
                "Yes, your resumes are processed in-memory and encrypted. We do not sell your personal data.",
              ),
              SizedBox(height: 32),
              _buildContactCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          icon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.5),
          ),
          hintText: "Search help articles...",
          hintStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFaqItem(context,String q, String a) {
    return ExpansionTile(
      title: Text(
        q,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            a,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mail_outline_rounded,
            color: AppColors.primary,
            size: 40,
          ),
          SizedBox(height: 16),
          Text(
            "Still need help?",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Our support team is available 24/7",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 12),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text("Contact Support"),
          ),
        ],
      ),
    );
  }
}
