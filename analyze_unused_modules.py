import re
import os

def parse_gitmodules(gitmodules_path):
    modules = []
    with open(gitmodules_path, 'r') as f:
        content = f.read()
    
    # Parse submodule entries
    # [submodule "typescript"]
    # path = site-lisp/extensions/languages/typescript
    # url = ...
    
    pattern = re.compile(r'\[submodule "(.*?)"\]\s*path = (.*?)\s*url', re.DOTALL)
    matches = pattern.findall(content)
    
    for name, path in matches:
        modules.append({
            'name': name.strip(),
            'path': path.strip(),
            'basename': os.path.basename(path.strip())
        })
    return modules

def scan_config_files(config_dirs):
    content = ""
    for directory in config_dirs:
        if not os.path.exists(directory):
            continue
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith(".el"):
                    with open(os.path.join(root, file), 'r', errors='ignore') as f:
                        content += f.read() + "\n"
    
    # Also include init.el and site-start.el
    root_files = ['init.el', 'site-start.el']
    for file in root_files:
        if os.path.exists(file):
            with open(file, 'r', errors='ignore') as f:
                content += f.read() + "\n"
                
    return content

def main():
    gitmodules_path = '.gitmodules'
    config_dirs = ['site-lisp/config', 'site-lisp/config-u']
    
    if not os.path.exists(gitmodules_path):
        print(".gitmodules not found")
        return

    modules = parse_gitmodules(gitmodules_path)
    config_content = scan_config_files(config_dirs)
    
    unused_modules = []
    
    print(f"Total submodules found: {len(modules)}")
    print("-" * 30)
    
    for module in modules:
        # Check if module name or basename appears in config
        # We use simple string matching, which might have false positives but is safer for "unused" detection
        # If it's NOT found, it's likely unused.
        
        # Some heuristics:
        # 1. Check for exact module name
        # 2. Check for basename (e.g. path is .../typescript, name is typescript)
        # 3. Check for feature name (often basename without .el)
        
        search_terms = {module['name'], module['basename']}
        if module['basename'].endswith('.el'):
            search_terms.add(module['basename'][:-3])
            
        found = False
        for term in search_terms:
            if term in config_content:
                found = True
                break
        
        if not found:
            unused_modules.append(module)
            print(f"Potentially unused: {module['name']} (path: {module['path']})")

    print("-" * 30)
    print(f"Total potentially unused: {len(unused_modules)}")

if __name__ == "__main__":
    main()
