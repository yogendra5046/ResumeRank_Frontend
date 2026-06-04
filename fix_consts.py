import os

def fix_file(file_path):
    if 'app_theme.dart' in file_path:
        return False
        
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original = content
    
    # Common widgets and decorators that we want to de-constify
    prefixes = [
        'const TextStyle(',
        'const Icon(',
        'const Divider(',
        'const BorderSide(',
        'const Border(',
        'const BoxDecoration(',
        'const Text(',
        'const Padding(',
        'const SizedBox(',
        'const Center(',
        'const Align(',
        'const Column(',
        'const Row(',
        'const Card(',
        'const Container(',
        'const ListTile(',
        'const EdgeInsets.',
        'const BorderRadius.',
        'const Color(',
    ]
    
    for prefix in prefixes:
        # replace const Widget( with Widget(
        replacement = prefix.replace('const ', '')
        content = content.replace(prefix, replacement)
        
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
                if fix_file(file_path):
                    print(f"Fixed const in: {file_path}")
                    modified_count += 1
    print(f"Total modified files: {modified_count}")

if __name__ == '__main__':
    main()
