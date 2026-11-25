#!/usr/bin/env python3
"""Genera los wallpapers de identidad MAOSPIX-COSMIC (3840x2160).

Misma familia que Maospix KDE: Maospix, Nord, Negro y Grafito (colores sólidos
con cuadrícula suave), más Rojo, Retro (neón synthwave con sol y suelo en
perspectiva) y Neon (Neon Dark futurista), con el logo neón MAOSPIX centrado, "COSMIC" y el lema.

Uso: python3 tools/gen-wallpapers.py   (desde la raíz del repo)
Salida: assets/wallpapers/generated/maospix-cosmic-*.png
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
LOGO = ROOT / "assets/branding/maospix-logo-neon.png"
FONTS = ROOT / "assets/fonts"
OUT = ROOT / "assets/wallpapers/generated"
W, H = 3840, 2160

CYAN = (79, 216, 232)
VIOLET = (179, 147, 245)
MAGENTA = (255, 64, 200)
RED = (235, 48, 72)
ORANGE = (255, 140, 60)

# nombre: (color de fondo, color de cuadrícula, brillo 0..1[, halo1, halo2])
VARIANTES = {
    "maospix": ((15, 21, 36), (32, 44, 68), 1.0),
    "nord": ((46, 58, 76), (62, 76, 98), 0.55),
    "negro": ((7, 9, 13), (20, 26, 34), 0.8),
    "grafito": ((43, 44, 49), (58, 59, 66), 0.45),
    "rojo": ((22, 7, 11), (54, 18, 26), 1.0, RED, ORANGE),
}
# colores del degradado del texto "COSMIC" por variante
TEXTO = {"rojo": (RED, ORANGE), "retro": (CYAN, MAGENTA), "neon": (CYAN, MAGENTA)}


def fondo(bg, grid, glow, c1=CYAN, c2=VIOLET):
    im = Image.new("RGB", (W, H), bg)
    d = ImageDraw.Draw(im)
    step = 80
    for x in range(0, W, step):
        d.line([(x, 0), (x, H)], fill=grid, width=2)
    for y in range(0, H, step):
        d.line([(0, y), (W, y)], fill=grid, width=2)
    # la cuadrícula se desvanece hacia los bordes (viñeta) para no cansar la vista
    mask = Image.new("L", (W, H), 0)
    ImageDraw.Draw(mask).ellipse((-W * 0.1, -H * 0.3, W * 1.1, H * 1.3), fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(500))
    im = Image.composite(im, Image.new("RGB", (W, H), bg), mask)

    # halos de color de la marca: cian detrás del logo, violeta abajo a la derecha
    for (cx, cy, r, col, a) in ((W // 2, 1000, 950, c1, 70), (3300, 1900, 1100, c2, 55)):
        layer = Image.new("RGB", (W, H), col)
        m = Image.new("L", (W, H), 0)
        ImageDraw.Draw(m).ellipse((cx - r, cy - r, cx + r, cy + r), fill=int(a * glow))
        im = Image.composite(layer, im, m.filter(ImageFilter.GaussianBlur(r * 0.6)))
    return im


def texto_espaciado(d, xy_centro, txt, font, fill, espacio):
    anchos = [d.textlength(c, font=font) for c in txt]
    total = sum(anchos) + espacio * (len(txt) - 1)
    x = xy_centro[0] - total / 2
    for c, w in zip(txt, anchos):
        d.text((x, xy_centro[1]), c, font=font, fill=fill, anchor="lm")
        x += w + espacio


def retro():
    """Synthwave: cielo violeta, sol rayado y suelo neón en perspectiva."""
    hz = int(H * 0.82)                         # línea del horizonte
    im = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(im)
    top, bot = (10, 4, 28), (78, 16, 92)
    for y in range(hz):
        t = (y / hz) ** 1.6
        d.line([(0, y), (W, y)], fill=tuple(int(top[i] * (1 - t) + bot[i] * t) for i in range(3)))
    d.rectangle((0, hz, W, H), fill=(12, 4, 26))

    # estrellas
    import random
    rnd = random.Random(7)
    for _ in range(260):
        x, y, r = rnd.randrange(W), rnd.randrange(int(hz * 0.8)), rnd.choice((1, 2, 2, 3))
        b = rnd.randrange(120, 255)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(b, b, min(255, b + 30)))

    # sol con degradado amarillo -> magenta y franjas recortadas abajo
    sx, sr = W // 2, 500
    sy = 820                          # sol detrás del logo, flotando sobre el horizonte
    sol = Image.new("RGB", (W, H))
    sd = ImageDraw.Draw(sol)
    for y in range(sy - sr, sy + sr):
        t = (y - (sy - sr)) / (2 * sr)
        a, b = (255, 220, 90), MAGENTA
        sd.line([(0, y), (W, y)], fill=tuple(int(a[i] * (1 - t) + b[i] * t) for i in range(3)))
    m = Image.new("L", (W, H), 0)
    md = ImageDraw.Draw(m)
    md.ellipse((sx - sr, sy - sr, sx + sr, sy + sr), fill=255)
    gap, y = 8, sy + 120
    while y < sy + sr:
        md.rectangle((0, y, W, y + gap), fill=0)
        y += 46
        gap += 7
    md.rectangle((0, hz, W, H), fill=0)
    halo = Image.new("L", (W, H), 0)
    ImageDraw.Draw(halo).ellipse((sx - sr * 1.5, sy - sr * 1.5, sx + sr * 1.5, sy + sr * 1.5), fill=110)
    im = Image.composite(Image.new("RGB", (W, H), MAGENTA), im, halo.filter(ImageFilter.GaussianBlur(260)))
    im = Image.composite(sol, im, m)

    # suelo: cuadrícula en perspectiva (magenta) con brillo
    g = Image.new("RGB", (W, H), (0, 0, 0))
    gd = ImageDraw.Draw(g)
    vx = W // 2
    for i in range(-40, 41):
        gd.line([(vx + i * 60, hz), (vx + i * 520, H)], fill=MAGENTA, width=4)
    k = 0
    while True:
        y = hz + int(6 * (1.32 ** k))
        if y > H:
            break
        gd.line([(0, y), (W, y)], fill=MAGENTA, width=3 + k // 4)
        k += 1
    gm = Image.new("L", (W, H), 0)
    ImageDraw.Draw(gm).rectangle((0, hz, W, H), fill=255)
    fade = Image.linear_gradient("L").resize((W, H - hz))
    gm.paste(fade.point(lambda a: 90 + a * 0.65), (0, hz))
    glowg = g.filter(ImageFilter.GaussianBlur(10))
    im = Image.composite(glowg, im, gm.point(lambda a: a * 0.8))
    im = Image.composite(g, im, Image.composite(gm, Image.new("L", (W, H), 0), g.convert("L")))
    # línea del horizonte brillante
    hl = Image.new("L", (W, H), 0)
    ImageDraw.Draw(hl).rectangle((0, hz - 3, W, hz + 3), fill=255)
    im = Image.composite(Image.new("RGB", (W, H), (255, 120, 230)), im, hl.filter(ImageFilter.GaussianBlur(14)))
    im = Image.composite(Image.new("RGB", (W, H), (255, 200, 245)), im, hl)
    return im


def neon():
    """Neon Dark futurista: negro profundo, malla hexagonal tenue, anillos y haces de neón."""
    import math
    bg = (4, 5, 11)
    im = Image.new("RGB", (W, H), bg)
    d = ImageDraw.Draw(im)
    # malla hexagonal muy tenue
    r = 70
    hw, hh = math.sqrt(3) * r, 1.5 * r
    row = 0
    y = -r
    while y < H + r:
        x0 = -hw + (hw / 2 if row % 2 else 0)
        x = x0
        while x < W + hw:
            pts = [(x + r * math.cos(math.radians(60 * k + 30)), y + r * math.sin(math.radians(60 * k + 30))) for k in range(6)]
            d.polygon(pts, outline=(16, 26, 40))
            x += hw
        y += hh
        row += 1
    vig = Image.new("L", (W, H), 0)
    ImageDraw.Draw(vig).ellipse((W * 0.1, H * 0.05, W * 0.9, H * 0.95), fill=255)
    im = Image.composite(im, Image.new("RGB", (W, H), bg), vig.filter(ImageFilter.GaussianBlur(420)))

    neon_l = Image.new("RGB", (W, H))
    nd = ImageDraw.Draw(neon_l)
    cx, cy = W // 2, 880
    # anillos concéntricos detrás del logo
    # anillos abiertos abajo para no cortar el texto
    for rr, col, wd in ((470, CYAN, 6), (530, VIOLET, 3), (620, MAGENTA, 2)):
        nd.arc((cx - rr, cy - rr, cx + rr, cy + rr), 150, 390, fill=col, width=wd)
    # arcos cortados (efecto HUD)
    for a0, a1 in ((190, 240), (300, 350)):
        nd.arc((cx - 760, cy - 760, cx + 760, cy + 760), a0, a1, fill=CYAN, width=5)
    # haces diagonales de luz
    for (x0, y0, x1, y1, col, wd) in ((-200, 1700, 1300, 200, CYAN, 4), (2500, 2300, 4100, 700, VIOLET, 4),
                                       (2700, -100, 4000, 1200, MAGENTA, 3), (-100, 2300, 900, 1300, MAGENTA, 3),
                                       (300, -100, 1100, 700, VIOLET, 2), (3000, 2200, 3600, 1600, CYAN, 2)):
        nd.line([(x0, y0), (x1, y1)], fill=col, width=wd)
    mask = neon_l.convert("L").point(lambda a: 255 if a > 0 else 0)
    im = Image.composite(neon_l.filter(ImageFilter.GaussianBlur(22)), im, mask.filter(ImageFilter.GaussianBlur(22)).point(lambda a: min(255, a * 2)))
    im = Image.composite(neon_l, im, mask)
    # halo central
    halo = Image.new("L", (W, H), 0)
    ImageDraw.Draw(halo).ellipse((cx - 700, cy - 700, cx + 700, cy + 700), fill=60)
    im = Image.composite(Image.new("RGB", (W, H), CYAN), im, halo.filter(ImageFilter.GaussianBlur(300)))
    return im


def marca(im, c1=CYAN, c2=VIOLET):
    cx = W // 2                        # bloque centrado
    logo = Image.open(LOGO).convert("RGBA")
    lh = 760
    logo = logo.resize((lh, lh), Image.LANCZOS)
    ly = 1080 - 560
    # brillo del logo
    glow = Image.new("RGBA", logo.size, CYAN + (0,))
    glow.putalpha(logo.getchannel("A").point(lambda a: a * 0.55))
    glow = glow.filter(ImageFilter.GaussianBlur(40))
    im.paste(glow, (cx - lh // 2, ly), glow)
    im.paste(logo, (cx - lh // 2, ly), logo)

    # "COSMIC" con degradado c1 -> c2
    big = ImageFont.truetype(str(FONTS / "Montserrat-Bold.ttf"), 210)
    y = ly + lh + 130
    m = Image.new("L", (W, H), 0)
    texto_espaciado(ImageDraw.Draw(m), (cx, y), "COSMIC", big, 255, 60)
    grad = Image.new("RGB", (W, H))
    gd = ImageDraw.Draw(grad)
    x0, x1 = cx - 420, cx + 420
    for x in range(x0, x1):
        t = (x - x0) / (x1 - x0)
        gd.line([(x, 0), (x, H)], fill=tuple(int(c1[i] * (1 - t) + c2[i] * t) for i in range(3)))
    gd.rectangle((0, 0, x0, H), fill=c1)
    gd.rectangle((x1, 0, W, H), fill=c2)
    sombra = Image.new("RGB", (W, H), (8, 4, 20))
    im.paste(sombra, (0, 0), m.filter(ImageFilter.GaussianBlur(40)).point(lambda a: a * 0.75))
    halo = Image.new("RGB", (W, H), c1)
    im.paste(halo, (0, 0), m.filter(ImageFilter.GaussianBlur(28)).point(lambda a: a * 0.5))
    im.paste(grad, (0, 0), m)

    small = ImageFont.truetype(str(FONTS / "Montserrat-Medium.ttf"), 54)
    ms = Image.new("L", (W, H), 0)
    texto_espaciado(ImageDraw.Draw(ms), (cx, y + 190), "ARCH  |  COSMIC  |  LIBRE", small, 255, 14)
    im.paste(sombra, (0, 0), ms.filter(ImageFilter.GaussianBlur(16)).point(lambda a: a * 0.8))
    texto_espaciado(ImageDraw.Draw(im), (cx, y + 190), "ARCH  |  COSMIC  |  LIBRE", small, (180, 192, 220), 14)
    return im


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    trabajos = [(n, lambda v=v: fondo(*v)) for n, v in VARIANTES.items()]
    trabajos.append(("retro", retro))
    trabajos.append(("neon", neon))
    for nombre, hacer in trabajos:
        im = marca(hacer(), *TEXTO.get(nombre, (CYAN, VIOLET)))
        dst = OUT / f"maospix-cosmic-{nombre}.png"
        im.save(dst, optimize=True)
        print(dst)


if __name__ == "__main__":
    main()
