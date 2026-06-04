import os
import re
import subprocess

def replace_in_file(file_path):
    # Skip the theme definition file to avoid circular references
    if 'app_theme.dart' in file_path:
        return False
        
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    
    # Perform standard replacements
    content = content.replace('AppColors.background', 'Theme.of(context).scaffoldBackgroundColor')
    content = content.replace('AppColors.textPrimary', 'Theme.of(context).colorScheme.onSurface')
    content = content.replace('AppColors.textSecondary', 'Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? const Color(0xFF64748B)')
    content = content.replace('AppColors.surface', 'Theme.of(context).colorScheme.surface')
    content = content.replace('AppColors.cardBackground', 'Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface')

    if content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    lib_dir = 'lib'
    modified_count = 0
    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                if replace_in_file(file_path):
                    print(f"Replaced colors in: {file_path}")
                    modified_count += 1
    print(f"Total modified files: {modified_count}")

if __name__ == '__main__':
    main()
