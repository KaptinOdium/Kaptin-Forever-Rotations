"""Verify the downloaded collection with Python 3; no external packages needed."""
from pathlib import Path
import hashlib
import json

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
expected = set()
for entry in manifest['files']:
    name = entry['path']
    path = (root / name).resolve()
    if not path.is_relative_to(root) or name in expected:
        raise SystemExit('Unsafe or duplicate manifest entry: ' + name)
    expected.add(name)
    if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != entry['sha256']:
        raise SystemExit('Missing or changed file: ' + name)
for toc in (root / 'Interface' / 'AddOns').rglob('*.toc'):
    for line in toc.read_text(encoding='utf-8-sig').splitlines():
        line = line.strip()
        if line and not line.startswith('#'):
            path = (toc.parent / line.replace('\\', '/')).resolve()
            if not path.is_relative_to(root) or not path.is_file():
                raise SystemExit('Missing TOC dependency: ' + toc.name + ': ' + line)
if len(manifest['profiles']) != 23 or len(manifest['addons']) != 5:
    raise SystemExit('Unexpected collection size')
print('Verified', len(expected), 'files, 23 profiles and 5 companions.')
