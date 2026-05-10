#!/usr/bin/env python3
"""Crop regions from zippysum_asset_sheet.png into assets/images/.

Requires: pip install Pillow
Run from repo root: python3 tooling/extract_zippysum_assets.py
"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Install Pillow: pip install Pillow", file=sys.stderr)
    sys.exit(1)

REPO_ROOT = Path(__file__).resolve().parent.parent
SHEET = REPO_ROOT / "assets/designs/generated/zippysum_asset_sheet.png"
OUT_DIR = REPO_ROOT / "assets/images"

# (name, x, y, width, height) — x,y is top-left.
# Horizontal logo: prior (y=620, h=190) sat above the bright band and clipped the
# wordmark; this aligns with the artwork ~y=655–835 on the 1536×1024 sheet.
# Mark: tile+bolt stack from the large logo (same x,y,w as logo_full). Height
# ~470px clears the lower-right tiles (~row 447); includes wordmark under cluster.
CROPS: list[tuple[str, int, int, int, int]] = [
    ("zippy_sum_logo_full.png", 60, 40, 700, 570),
    # Primary app icon (right column on sheet — clean 380×380, no caption bleed).
    ("zippy_sum_app_icon_source.png", 1135, 70, 380, 380),
    # Stop before x≈827 where the next sheet graphic bleeds (was 760 wide → 832).
    ("zippy_sum_logo_horizontal.png", 72, 652, 755, 218),
    # ~470px tall: enough for full + tile / bolt base + glow; wordmark overlaps
    # lower rows. For a text-free mark use zippy_sum_app_icon_source.png.
    ("zippy_sum_mark.png", 60, 40, 700, 470),
]


def main() -> None:
    if not SHEET.is_file():
        print(f"Missing sheet: {SHEET}", file=sys.stderr)
        sys.exit(1)

    im = Image.open(SHEET).convert("RGBA")
    w, h = im.size
    if (w, h) != (1536, 1024):
        print(f"Warning: expected 1536x1024, got {w}x{h}", file=sys.stderr)

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # Alternate: left-column icon, tight crop + letterboxed (caption excluded).
    _write_left_app_icon_alt(im)

    for filename, x, y, width, height in CROPS:
        x2, y2 = x + width, y + height
        if x < 0 or y < 0 or x2 > w or y2 > h:
            print(
                f"Warning: {filename} crop ({x},{y},{width},{height}) "
                f"extends past image {w}x{h}",
                file=sys.stderr,
            )
        box = (max(0, x), max(0, y), min(w, x2), min(h, y2))
        crop = im.crop(box)
        out_path = OUT_DIR / filename
        crop.save(out_path, "PNG")
        print(f"Wrote {out_path.relative_to(REPO_ROOT)} ({crop.size[0]}x{crop.size[1]})")


def _write_left_app_icon_alt(sheet: Image.Image) -> None:
    tight = sheet.crop((770, 70, 1135, 320))
    side = 380
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 255))
    ox = (side - tight.width) // 2
    oy = (side - tight.height) // 2
    canvas.paste(tight, (ox, oy))
    out_path = OUT_DIR / "zippy_sum_app_icon_source_alt.png"
    canvas.save(out_path, "PNG")
    print(
        f"Wrote {out_path.relative_to(REPO_ROOT)} ({side}×{side}, "
        f"icon {tight.width}×{tight.height} centered)"
    )


if __name__ == "__main__":
    main()
