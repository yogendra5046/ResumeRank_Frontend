import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';

class ATSXRayScreen extends StatelessWidget {
  final AnalysisResult result;

  const ATSXRayScreen({super.key, required this.result});

  // Comprehensive professional action verbs (60+)
  static const Set<String> _actionVerbs = {
    'achieved',
    'accelerated',
    'architected',
    'automated',
    'built',
    'collaborated',
    'consolidated',
    'created',
    'delivered',
    'deployed',
    'designed',
    'developed',
    'directed',
    'drove',
    'enhanced',
    'established',
    'executed',
    'expanded',
    'generated',
    'implemented',
    'improved',
    'increased',
    'initiated',
    'integrated',
    'launched',
    'led',
    'managed',
    'mentored',
    'migrated',
    'negotiated',
    'onboarded',
    'optimized',
    'orchestrated',
    'oversaw',
    'partnered',
    'pioneered',
    'planned',
    'prioritized',
    'produced',
    'reduced',
    'refactored',
    'resolved',
    'revamped',
    'scaled',
    'secured',
    'shipped',
    'simplified',
    'spearheaded',
    'streamlined',
    'transformed',
    'transitioned',
    'unified',
    'upgraded',
    'utilized',
  };

  // Filler/weak phrases to flag — matched as substrings of lines
  static const List<String> _warningPhrases = [
    'responsible for',
    'familiar with',
    'hardworking',
    'team player',
    'motivated',
    'detail-oriented',
    'go-getter',
    'synergy',
    'passionate about',
    'results-driven',
    'self-starter',
    'proactive',
    'dynamic professional',
  ];

  @override
  Widget build(BuildContext context) {
    final jdKeywords = result.jdKeywords
        .map((k) => k.toLowerCase().trim())
        .toSet();
    final missingKeywords = result.missingKeywords
        .map((k) => k.toLowerCase().trim())
        .toSet();
    final matchedKeywords = result.matchedSkills
        .map((s) => (s['name'] as String? ?? '').toLowerCase().trim())
        .toSet();

    final rawText = result.rawResumeText;
    final wordCount = rawText.trim().split(RegExp(r'\s+')).length;
    final lineCount = rawText.trim().split('\n').length;

    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ATS System View',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.copy_rounded, color: Colors.white70),
            tooltip: 'Copy raw text',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: rawText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Raw text copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: Colors.white.withValues(alpha: 0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Words', '$wordCount'),
                _buildStat('Lines', '$lineCount'),
                _buildStat('JD Keywords', '${jdKeywords.length}'),
                _buildStat('Matched', '${matchedKeywords.length}'),
              ],
            ),
          ),
          // Legend
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: Colors.white.withValues(alpha: 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Matched', AppColors.primary),
                _buildLegendItem('Action Verb', AppColors.success),
                _buildLegendItem('Filler', AppColors.warning),
                _buildLegendItem('Missing', Colors.redAccent),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: rawText.isEmpty
                    ? Center(
                        child: Text(
                          'No text extracted from resume.',
                          style: GoogleFonts.firaCode(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          style: GoogleFonts.firaCode(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.7,
                          ),
                          children: _buildHighlightedText(
                            rawText,
                            jdKeywords,
                            missingKeywords,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<TextSpan> _buildHighlightedText(
    String text,
    Set<String> jdKeywords,
    Set<String> missingKeywords,
  ) {
    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check if this entire line contains a warning phrase
      final lowerLine = line.toLowerCase();
      final hasWarning = _warningPhrases.any((p) => lowerLine.contains(p));

      if (hasWarning) {
        // Highlight the whole line in warning color
        spans.add(
          TextSpan(
            text: line,
            style: TextStyle(
              color: Color(0xFFFBBF24),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFFFBBF24),
            ),
          ),
        );
      } else {
        // Word-by-word analysis
        final words = line.split(RegExp(r'(\s+)'));
        for (final word in words) {
          final clean = word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');

          if (clean.isEmpty) {
            spans.add(TextSpan(text: word));
          } else if (jdKeywords.contains(clean) &&
              !missingKeywords.contains(clean)) {
            // Matched JD keyword — elite/indigo
            spans.add(
              TextSpan(
                text: word,
                style: TextStyle(
                  color: Color(0xFF818CF8),
                  fontWeight: FontWeight.bold,
                  backgroundColor: Color(0x1A818CF8),
                ),
              ),
            );
          } else if (missingKeywords.contains(clean)) {
            // In JD but NOT in resume — red (shouldn't appear here but guard anyway)
            spans.add(
              TextSpan(
                text: word,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else if (_actionVerbs.contains(clean)) {
            // Strong action verb — teal
            spans.add(
              TextSpan(
                text: word,
                style: TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            spans.add(TextSpan(text: word));
          }
        }
      }

      // Add newline between lines (but not after last)
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }
}
