"""Redraws the launcher icon at 1024 px and writes every size the iOS
AppIcon set asks for. iOS masks the corners itself, so the art is full-bleed
and opaque. Geometry is on the 192 px grid of the Android icon."""
import json
from pathlib import Path
from PIL import Image, ImageDraw

BG = (18, 15, 12)
RED = (216, 92, 56)
CREAM = [(244, 236, 218), (236, 225, 204)]
INK = (8, 6, 4)
# (x0, x1, top, label_top, label_bottom)
BOOKS = [(29, 41, 70, 77, 79), (45, 58, 56, 64, 65), (62, 75, 65, 72, 74),
         (79, 92, 51, 58, 59), (96, 109, 60, 68, 69), (113, 126, 66, 74, 75),
         (130, 143, 53, 61, 62), (147, 159, 62, 69, 71)]
BOTTOM, SHELF = 150, (23, 156, 169, 159)

def draw(size=1024, ss=4):
    n = size * ss
    s = n / 192
    im = Image.new('RGB', (n, n), BG)
    d = ImageDraw.Draw(im)
    box = lambda a, b, c, e, fill: d.rectangle([a * s, b * s, (c + 1) * s - 1, (e + 1) * s - 1], fill=fill)
    for i, (x0, x1, top, lt, lb) in enumerate(BOOKS):
        box(x0, top, x1, BOTTOM - 1, RED if i == 0 else CREAM[i % 2])
        box(x0 + 2, lt, x1 - 2, lb, INK)
    box(*SHELF, RED)
    return im.resize((size, size), Image.LANCZOS)

root = Path(__file__).resolve().parent.parent
iconset = root / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
master = draw()
for img in json.loads((iconset / 'Contents.json').read_text())['images']:
    px = round(float(img['size'].split('x')[0]) * int(img['scale'][0]))
    master.resize((px, px), Image.LANCZOS).save(iconset / img['filename'])
print('wrote icons to', iconset)
