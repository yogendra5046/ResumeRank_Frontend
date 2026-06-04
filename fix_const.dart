import 'dart:io';

void main() {
  final files = [
    'lib/screens/settings_screen.dart',
    'lib/screens/interview_prep_screen.dart',
    'lib/screens/rewrite_screen.dart',
    'lib/screens/linkedin_hub_screen.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();
    
    // Fix Divider with non-constant values
    content = content.replaceAll('const Divider(height: 32, color: AppColors.primary.withValues', 'Divider(height: 32, color: AppColors.primary.withValues');
    content = content.replaceAll('const Divider(height: 24, color: AppColors.primary.withValues', 'Divider(height: 24, color: AppColors.primary.withValues');
    
    // Fix Icon with non-constant values
    content = content.replaceAll('const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary.withValues', 'Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary.withValues');

    file.writeAsStringSync(content);
    print('Updated $path');
  }
}
