
import os

def replace_imports(root_dir):
    print(f"Scanning {root_dir}...")
    count = 0
    for subdir, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith(".dart"):
                filepath = os.path.join(subdir, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    original_content = content
                    
                    # Premium Header Replacements
                    content = content.replace("import '../components/premium_header.dart';", "import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';")
                    content = content.replace("import '../../components/premium_header.dart';", "import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';")
                    
                    # App Theme Replacements
                    content = content.replace("import '../theme/app_theme.dart';", "import 'package:proyecto_empoderate/ui/theme/app_theme.dart';")
                    content = content.replace("import '../../theme/app_theme.dart';", "import 'package:proyecto_empoderate/ui/theme/app_theme.dart';")

                     # Bottom Nav Bar Replacements (if any lingering relative imports)
                    content = content.replace("import '../navigation/bottom_nav_bar.dart';", "import 'package:proyecto_empoderate/ui/components/footer/bottom_nav_bar.dart';")

                    if content != original_content:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(content)
                        print(f"Updated: {filepath}")
                        count += 1
                except Exception as e:
                    print(f"Error processing {filepath}: {e}")
    print(f"Total files updated: {count}")

if __name__ == "__main__":
    replace_imports("lib")
