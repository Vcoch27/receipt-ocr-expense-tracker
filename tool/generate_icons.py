"""Create launcher icon sizes from the transparent project mark (requires Pillow)."""

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "brand" / "receipt-mark.png"
BACKGROUND = (246, 248, 247)


def icon(size: int) -> Image.Image:
    mark = Image.open(SOURCE).convert("RGBA")
    bounds = mark.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError("The brand mark is fully transparent")
    mark = mark.crop(bounds)
    target = round(size * 0.76)
    mark.thumbnail((target, target), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (size, size), BACKGROUND + (255,))
    canvas.alpha_composite(mark, ((size - mark.width) // 2, (size - mark.height) // 2))
    return canvas.convert("RGB")


def main() -> None:
    icon(1024).save(ROOT / "assets" / "brand" / "app-icon.png")
    for bucket, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        path = ROOT / "android" / "app" / "src" / "main" / "res" / f"mipmap-{bucket}" / "ic_launcher.png"
        icon(size).save(path)

    ios = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    for entry in json.loads((ios / "Contents.json").read_text(encoding="utf-8"))["images"]:
        filename = entry.get("filename")
        if filename:
            points = float(entry["size"].split("x")[0])
            scale = int(entry["scale"].removesuffix("x"))
            icon(round(points * scale)).save(ios / filename)


if __name__ == "__main__":
    main()
