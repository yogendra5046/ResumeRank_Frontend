import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/analysis_result.dart';
//import '../theme/app_theme.dart';
//import '../widgets/premium_widgets.dart';

class RoastModeScreen extends StatelessWidget {
  final AnalysisResult result;

  const RoastModeScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A), // Dark Navy
      appBar: AppBar(
        title: Text(
          "ROAST MODE 🔥",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                _buildFlameHeader(),
                SizedBox(height: 32),
                if (result.roast.isEmpty)
                  _buildEmptyRoast()
                else
                  ...result.roast.map((comment) => _buildRoastBubble(comment)),
                SizedBox(height: 40),
                _buildBurnButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlameHeader() {
    return Column(
      children: [
        Text(
          "💀",
          style: TextStyle(fontSize: 64),
        ).animate(onPlay: (c) => c.repeat()).shake(duration: 1000.ms),
        SizedBox(height: 16),
        Text(
          "BRUTAL TRUTH",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFFF97316), // Orange-500
            letterSpacing: 2,
          ),
        ),
        Text(
          "Prepare for third-degree burns.",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRoastBubble(String comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(0xFFF97316).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🔥", style: TextStyle(fontSize: 20)),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              comment,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1);
  }

  Widget _buildEmptyRoast() {
    return Center(
      child: Text(
        "Your resume is too boring to even roast. Try adding something worth insulting.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildBurnButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFF97316),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text("I'VE HAD ENOUGH 😭"),
    );
  }
}
