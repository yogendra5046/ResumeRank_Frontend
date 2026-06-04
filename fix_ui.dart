import 'dart:io';

void main() {
  final files = [
    'lib/screens/linkedin_hub_screen.dart',
    'lib/screens/interview_prep_screen.dart',
    'lib/screens/rewrite_screen.dart',
    'lib/screens/skill_details_screen.dart',
    'lib/screens/settings_screen.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();
    
    content = content.replaceAll('color: Colors.white,', 'color: AppColors.textPrimary,');
    content = content.replaceAll('color: Colors.white)', 'color: AppColors.textPrimary)');
    content = content.replaceAll('color: Colors.white70,', 'color: AppColors.textSecondary,');
    content = content.replaceAll('color: Colors.white70)', 'color: AppColors.textSecondary)');
    content = content.replaceAll('color: Colors.white54,', 'color: AppColors.textSecondary,');
    content = content.replaceAll('color: Colors.white54)', 'color: AppColors.textSecondary)');
    content = content.replaceAll('color: Colors.white38,', 'color: AppColors.textSecondary,');
    content = content.replaceAll('color: Colors.white38)', 'color: AppColors.textSecondary)');
    content = content.replaceAll('color: Colors.white24,', 'color: AppColors.primary.withValues(alpha: 0.4),');
    content = content.replaceAll('color: Colors.white24)', 'color: AppColors.primary.withValues(alpha: 0.4))');
    content = content.replaceAll('color: Colors.white10,', 'color: AppColors.primary.withValues(alpha: 0.1),');
    content = content.replaceAll('color: Colors.white10)', 'color: AppColors.primary.withValues(alpha: 0.1))');
    
    // Fix CircleAvatar which has dark background so it needs white text
    content = content.replaceAll(
      'color: AppColors.textPrimary, fontWeight: FontWeight.bold',
      'color: Colors.white, fontWeight: FontWeight.bold'
    );
    
    // In interview_prep_screen:
    // CircleAvatar(radius: 10, backgroundColor: AppColors.primary, child: Text(letter, style: const TextStyle(fontSize: 10, color: AppColors.textPrimary, fontWeight: FontWeight.bold)))
    // My quick fix above restores it to Colors.white.

    file.writeAsStringSync(content);
    print('Updated $path');
  }
}
