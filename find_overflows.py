import os
import re

def check_flutter_files(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                # Look for Scaffold body: Column without SingleChildScrollView
                if 'Scaffold(' in content and 'body: Column(' in content:
                    print(f"Potential Overflow: {filepath} uses 'body: Column(' directly")
                    
                # Look for bottom sheet or dialog content without scroll
                if 'showModalBottomSheet' in content:
                    # check if the builder returns a Column without SingleChildScrollView
                    if re.search(r'builder:.*?=>\s*Column\(', content, re.DOTALL):
                        print(f"Potential Overflow: {filepath} uses Column directly in showModalBottomSheet")
                        
                # Look for TabBarView children that are just Column
                if 'TabBarView(' in content and re.search(r'children:\s*\[\s*Column\(', content):
                    print(f"Potential Overflow: {filepath} uses Column directly in TabBarView")

check_flutter_files('c:/resanalyzer_backend/flutter/resume_ai/lib')
