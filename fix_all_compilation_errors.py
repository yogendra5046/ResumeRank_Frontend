import os

def replace_in_file(filepath, replacements):
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = content
    for target, replacement in replacements:
        modified = modified.replace(target, replacement)
    
    if modified != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(modified)
        print(f"Updated {filepath}")
    else:
        print(f"No changes in {filepath}")

# signup_page.dart
replace_in_file(
    'lib/features/auth/presentation/pages/signup_page.dart',
    [
        ('iconTheme: const IconThemeData(color: Theme.of(context).colorScheme.onSurface),', 'iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),'),
    ]
)

# signup_screen.dart
replace_in_file(
    'lib/screens/auth/signup_screen.dart',
    [
        ('iconTheme: const IconThemeData(color: Theme.of(context).colorScheme.onSurface),', 'iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),'),
    ]
)

# test/screens/dashboard_screen_test.dart
replace_in_file(
    'test/screens/dashboard_screen_test.dart',
    [
        ("import 'package:resume_ai/screens/dashboard_screen.dart';", "import 'package:resume_ai/features/analysis/presentation/pages/dashboard_page.dart';"),
        ("home: DashboardScreen(result: mockResult)", "home: DashboardPage(result: mockResult)"),
    ]
)

# test/screens/resume_profiles_test.dart
replace_in_file(
    'test/screens/resume_profiles_test.dart',
    [
        ("import 'package:resume_ai/screens/dashboard_screen.dart';", "import 'package:resume_ai/features/analysis/presentation/pages/dashboard_page.dart';"),
        ("child: DashboardScreen(result: result)", "child: DashboardPage(result: result)"),
    ]
)

print("Replacement of signups and tests complete.")
