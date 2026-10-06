"""Build the installable version 01 archive using Python's standard library."""
import hashlib
import json
import struct
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PET = ROOT / 'pets' / 'SodiWorm'
OUTPUT = ROOT / 'release'
FILES = ['pet.json', 'spritesheet.png', 'animation-mappings.json', 'preview.html', 'README.md', 'LICENSE']

def main():
    config = json.loads((PET / 'pet.json').read_text(encoding='utf-8'))
    assert config['displayName'] == 'SodiWorm'
    assert config['spriteVersionNumber'] == 2
    assert config['spritesheetPath'] == 'spritesheet.png'
    sprite = (PET / 'spritesheet.png').read_bytes()
    assert sprite[:8] == b'\x89PNG\r\n\x1a\n'
    assert struct.unpack('>II', sprite[16:24]) == (1536, 2288)
    assert hashlib.sha256(sprite).hexdigest() == '7d2e8f13a5e33f80ad4ceac60713aba93c494bcf8892830f55e9e91634d56ff1', 'Sprite differs from the validated release artwork'
    assert (PET / 'LICENSE').read_bytes() == (ROOT / 'LICENSE').read_bytes()
    OUTPUT.mkdir(exist_ok=True)
    archive = OUTPUT / 'SodiWorm-v01.zip'
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
        for name in FILES:
            z.write(PET / name, f'SodiWorm/{name}')
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        assert set(z.namelist()) == {f'SodiWorm/{name}' for name in FILES}
        packed = json.loads(z.read('SodiWorm/pet.json'))
        assert f"SodiWorm/{packed['spritesheetPath']}" in z.namelist()
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    (OUTPUT / 'SHA256SUMS.txt').write_text(f'{digest}  {archive.name}\n', encoding='utf-8')
    print(f'Validated release archive: {archive}\nBytes: {archive.stat().st_size}\nSHA256: {digest}')

if __name__ == '__main__':
    main()
