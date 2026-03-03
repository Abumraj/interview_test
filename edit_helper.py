import sys

filepath = r'c:\interview\lib\screens\product_detail_screen.dart'

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add _editingInitialized flag
old1 = 'bool _addedToBag = false;'
new1 = 'bool _addedToBag = false;\n  bool _editingInitialized = false;'
if old1 in content:
    content = content.replace(old1, new1, 1)
    print('OK: Added _editingInitialized')
else:
    print('WARN: Could not find _addedToBag line')
    sys.exit(1)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print('Done')
