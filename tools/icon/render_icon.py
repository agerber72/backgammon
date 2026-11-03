# Builds all app icon sizes from assets/icon/app_icon.png, the output of
# render_icon_art.py. Run inside Blender, which provides numpy and PNG support:
#   ./tools/blender/app/blender.exe -b --factory-startup --python tools/icon/render_icon.py
import struct
from pathlib import Path

import bpy
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets' / 'icon' / 'app_icon.png'
ROUNDED = ROOT / 'assets' / 'icon' / 'app_icon_rounded.png'
RES = ROOT / 'android' / 'app' / 'src' / 'main' / 'res'
# Launchers crop adaptive icons, so the art shrinks onto a canvas in the brand
# color of p2g-it; the points reach the edge, so the edge color would not fit.
ADAPTIVE_ART_SCALE = 0.85
BRAND = (0x5B / 255, 0x84 / 255, 0xC3 / 255, 1.0)
CORNER_RADIUS = 0.22


def load_art():
    image = bpy.data.images.load(str(SOURCE))
    side = image.size[0]
    pixels = np.array(image.pixels[:], dtype=np.float32).reshape(side, side, 4)
    bpy.data.images.remove(image)
    return pixels


def rounded(art):
    """Square with rounded, transparent corners."""
    side = art.shape[0]
    radius = side * CORNER_RADIUS
    y, x = np.mgrid[0:side, 0:side].astype(np.float32) + 0.5
    dx = np.maximum(np.abs(x - side / 2) - (side / 2 - radius), 0)
    dy = np.maximum(np.abs(y - side / 2) - (side / 2 - radius), 0)
    alpha = np.clip(radius - np.hypot(dx, dy) + 0.5, 0, 1)
    result = art.copy()
    result[..., 3] = alpha
    return result


def adaptive(art):
    """Places the art in the middle of a canvas in the brand color."""
    side = art.shape[0]
    inner = int(side * ADAPTIVE_ART_SCALE)
    image = bpy.data.images.new('inner', side, side, alpha=True)
    image.pixels.foreach_set(art.ravel())
    image.scale(inner, inner)
    small = np.array(image.pixels[:], dtype=np.float32).reshape(inner, inner, 4)
    bpy.data.images.remove(image)
    canvas = np.ones_like(art) * np.array(BRAND, dtype=np.float32)
    start = (side - inner) // 2
    canvas[start:start + inner, start:start + inner] = small
    return canvas


def save(art, size, path):
    side = art.shape[0]
    image = bpy.data.images.new('icon', side, side, alpha=True)
    image.pixels.foreach_set(art.ravel())
    if size != side:
        image.scale(size, size)
    path.parent.mkdir(parents=True, exist_ok=True)
    image.filepath_raw = str(path)
    image.file_format = 'PNG'
    image.save()
    bpy.data.images.remove(image)


def save_ico(art, sizes, path):
    """Writes an .ico file with one embedded PNG per size."""
    temporary = path.with_suffix('.tmp.png')
    images = []
    for size in sizes:
        save(art, size, temporary)
        images.append(temporary.read_bytes())
    temporary.unlink()
    offset = 6 + 16 * len(sizes)
    header = struct.pack('<HHH', 0, 1, len(sizes))
    entries = b''
    for size, data in zip(sizes, images):
        side = 0 if size == 256 else size
        entries += struct.pack('<BBBBHHII', side, side, 0, 0, 1, 32, len(data),
                               offset)
        offset += len(data)
    path.write_bytes(header + entries + b''.join(images))


def main():
    square = load_art()
    safe = adaptive(square)
    art = rounded(square)
    save(art, art.shape[0], ROUNDED)

    densities = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
    for name, factor in densities.items():
        folder = RES / f'mipmap-{name}'
        save(art, int(48 * factor), folder / 'ic_launcher.png')
        save(safe, int(108 * factor), folder / 'ic_launcher_foreground.png')

    web = ROOT / 'web'
    save(art, 32, web / 'favicon.png')
    save(art, 192, web / 'icons' / 'Icon-192.png')
    save(art, 512, web / 'icons' / 'Icon-512.png')
    save(safe, 192, web / 'icons' / 'Icon-maskable-192.png')
    save(safe, 512, web / 'icons' / 'Icon-maskable-512.png')

    save_ico(art, [16, 32, 48, 256],
             ROOT / 'windows' / 'runner' / 'resources' / 'app_icon.ico')


main()
