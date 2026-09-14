from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT.parent / "output" / "yemeni-world-preview-board.png"
W, H = 390, 844
INK = "#17211b"
FOREST = "#126a4a"
MINT = "#e6f3ed"
CORAL = "#e9684a"
CANVAS = "#f8f9f6"
LINE = "#e3e7e2"
MUTED = "#66736b"
WHITE = "#ffffff"
GOLD = "#d5a62e"
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def font(size, bold=False):
    return ImageFont.truetype(BOLD if bold else FONT, size)


def rtl(draw, xy, text, size=14, color=INK, bold=False, anchor="ra"):
    draw.text(xy, text, fill=color, font=font(size, bold), anchor=anchor, direction="rtl")


def rr(draw, box, radius=8, fill=WHITE, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def chrome(draw, title, active=0, back=False):
    draw.rectangle((0, 0, W, 64), fill=CANVAS)
    if back:
        rtl(draw, (28, 35), "←", 23, INK, anchor="mm")
        rtl(draw, (W - 20, 38), title, 18, INK, True)
    else:
        rr(draw, (W - 53, 15, W - 19, 49), 6, FOREST)
        rtl(draw, (W - 36, 34), "ي", 20, WHITE, True, "mm")
        rtl(draw, (W - 64, 37), title, 17, INK, True)
    rtl(draw, (25, 37), "♢", 22, INK, anchor="mm")
    draw.rectangle((0, H - 72, W, H), fill=WHITE)
    draw.line((0, H - 72, W, H - 72), fill=LINE)
    items = [("⌂", "الرئيسية"), ("⌕", "استكشف"), ("+", "إضافة"), ("▤", "الطلبات"), ("○", "حسابي")]
    for i, (ico, label) in enumerate(items):
        x = W - 39 - i * 78
        color = FOREST if i == active else MUTED
        if i == 2:
            draw.ellipse((x - 20, H - 88, x + 20, H - 48), fill=CORAL)
            rtl(draw, (x, H - 68), ico, 25, WHITE, True, "mm")
        else:
            rtl(draw, (x, H - 47), ico, 20, color, anchor="mm")
        rtl(draw, (x, H - 20), label, 10, color, True, "mm")


def onboarding():
    src = Image.open(ROOT / "assets/images/onboarding.png").convert("RGB")
    ratio = max(W / src.width, H / src.height)
    src = src.resize((int(src.width * ratio), int(src.height * ratio)), Image.Resampling.LANCZOS)
    x = (src.width - W) // 2
    img = src.crop((x, 0, x + W, H))
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    for y in range(H):
        alpha = int(35 + 205 * (y / H) ** 2.2)
        od.line((0, y, W, y), fill=(23, 33, 27, min(alpha, 238)))
    img = Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")
    d = ImageDraw.Draw(img)
    rr(d, (W - 66, 20, W - 22, 64), 7, CORAL)
    rtl(d, (W - 44, 43), "ي", 27, WHITE, True, "mm")
    rr(d, (18, 24, 92, 58), 7, "#17211b99", "#ffffff88")
    rtl(d, (55, 43), "عربي / EN", 11, WHITE, True, "mm")
    rtl(d, (W - 24, 550), "يمني", 43, WHITE, True)
    rtl(d, (W - 24, 603), "حول العالم", 43, WHITE, True)
    rtl(d, (W - 24, 642), "أشخاص وخدمات ومنشآت يمنية،", 16, "#d5e0d9")
    rtl(d, (W - 24, 669), "أينما كانت وجهتك.", 16, "#d5e0d9")
    rr(d, (22, 694, W - 22, 753), 8, "#223128dd", "#ffffff20")
    rtl(d, (W - 44, 728), "ابحث قبل سفرك أو اكتشف ما حولك الآن", 13, WHITE, True)
    rr(d, (22, 770, W - 22, 824), 8, CORAL)
    rtl(d, (W / 2, 799), "ابدأ الاستكشاف", 15, WHITE, True, "mm")
    return img


def listing(draw, y, name, sub, city, score, color=MINT):
    rr(draw, (20, y, 104, y + 84), 7, color)
    rtl(draw, (62, y + 42), name[0], 28, FOREST, True, "mm")
    rtl(draw, (W - 122, y + 20), name + "  ✓", 14, INK, True)
    rtl(draw, (W - 122, y + 43), sub, 12, MUTED)
    rtl(draw, (W - 122, y + 67), f"★ {score}    ⌖ {city}", 10, MUTED)
    draw.line((20, y + 96, W - 20, y + 96), fill=LINE)


def home():
    img = Image.new("RGB", (W, H), CANVAS)
    d = ImageDraw.Draw(img)
    chrome(d, "يمني حول العالم", 0)
    rtl(d, (W - 20, 87), "⌖ الرياض، السعودية  ⌄", 12, INK, True)
    rr(d, (20, 101, W - 20, 155), 8, WHITE, LINE)
    rtl(d, (W - 55, 133), "ماذا تبحث عنه؟", 14, "#849087")
    rtl(d, (W - 27, 130), "⌕", 20, MUTED, anchor="mm")
    rr(d, (20, 169, 191, 239), 8, WHITE, LINE)
    rr(d, (201, 169, W - 20, 239), 8, WHITE, LINE)
    rtl(d, (W - 216, 194), "قريب مني", 13, INK, True)
    rtl(d, (W - 216, 216), "حسب المسافة", 10, MUTED)
    rtl(d, (177, 194), "عروض اليوم", 13, INK, True)
    rtl(d, (177, 216), "وفر أكثر", 10, MUTED)
    rtl(d, (W - 20, 277), "التصنيفات", 18, INK, True)
    for i, (ico, label) in enumerate([("文", "ترجمة"), ("☕", "مطاعم"), ("↗", "نقل"), ("⌂", "سكن")]):
        x = W - 53 - i * 86
        rr(d, (x - 25, 295, x + 25, 345), 8, MINT if i % 2 == 0 else "#ffede7")
        rtl(d, (x, 320), ico, 18, FOREST if i % 2 == 0 else CORAL, True, "mm")
        rtl(d, (x, 363), label, 11, INK, True, "mm")
    rtl(d, (W - 20, 410), "موصى به لك", 18, INK, True)
    listing(d, 430, "محمد علي", "مترجم ومرافق أعمال", "نيودلهي", "4.9")
    listing(d, 535, "باب اليمن", "مطعم يمني أصيل", "الرياض", "4.8", "#ffede7")
    listing(d, 640, "أروى الحكيمي", "مصورة فعاليات وفيديو", "الرياض", "4.9")
    return img


def search():
    img = Image.new("RGB", (W, H), CANVAS)
    d = ImageDraw.Draw(img)
    chrome(d, "استكشف", 1)
    rr(d, (20, 76, W - 20, 130), 8, WHITE, LINE)
    rtl(d, (W - 55, 108), "مترجم يمني في نيودلهي", 13, INK)
    rtl(d, (W - 28, 105), "⌕", 20, MUTED, anchor="mm")
    for x, text in [(W - 20, "الدولة⌄"), (W - 112, "المدينة⌄"), (W - 210, "قريب مني")]:
        width = 82
        rr(d, (x - width, 143, x, 181), 7, WHITE, LINE)
        rtl(d, (x - width / 2, 163), text, 11, INK, True, "mm")
    for i, label in enumerate(["ترجمة", "مطاعم", "نقل", "سكن"]):
        x = W - 20 - i * 78
        rr(d, (x - 69, 195, x, 231), 7, MINT if i == 0 else WHITE, "#bcdacb" if i == 0 else LINE)
        rtl(d, (x - 34, 214), label, 10, FOREST if i == 0 else INK, True, "mm")
    rtl(d, (W - 20, 258), "نتيجة واحدة مرتبة حسب الصلة", 11, MUTED)
    listing(d, 280, "محمد علي", "مترجم ومرافق أعمال", "نيودلهي، الهند", "4.9")
    rr(d, (20, 403, W - 20, 478), 8, MINT)
    rtl(d, (W - 37, 431), "متاح الآن • موثق", 12, FOREST, True)
    rtl(d, (W - 37, 458), "يبدأ من 45 USD", 13, FOREST, True)
    rtl(d, (W - 20, 527), "ابحث قبل السفر", 20, INK, True)
    rtl(d, (W - 20, 557), "حدد الدولة والمدينة والخدمة حتى لو لم تكن", 12, MUTED)
    rtl(d, (W - 20, 579), "موجودًا في وجهتك الآن.", 12, MUTED)
    return img


def request_detail():
    img = Image.new("RGB", (W, H), CANVAS)
    d = ImageDraw.Draw(img)
    chrome(d, "تفاصيل الطلب", 3, True)
    rtl(d, (W - 20, 106), "أحتاج مصورًا في الرياض", 23, INK, True)
    rtl(d, (W - 20, 137), "⌖ الرياض، السعودية  •  منذ 18 دقيقة", 11, MUTED)
    rtl(d, (W - 20, 184), "تغطية فعالية يوم الجمعة من 6 إلى 10 مساءً.", 13, INK)
    rtl(d, (W - 20, 221), "الميزانية: 1200 USD", 13, FOREST, True)
    rtl(d, (W - 20, 273), "3 عروض مقدمة", 18, INK, True)
    names = [("أروى الحكيمي", "4.9", "850"), ("منار للإنتاج", "4.8", "980"), ("عدنان الصبري", "4.7", "700")]
    for i, (name, score, price) in enumerate(names):
        y = 294 + i * 101
        rr(d, (20, y, W - 20, y + 90), 8, WHITE, LINE)
        draw_x = W - 48
        d.ellipse((draw_x - 19, y + 15, draw_x + 19, y + 53), fill=MINT)
        rtl(d, (draw_x, y + 34), name[0], 15, FOREST, True, "mm")
        rtl(d, (W - 79, y + 31), name + "  ✓", 13, INK, True)
        rtl(d, (W - 79, y + 56), f"★ {score} • تسليم خلال يومين", 10, MUTED)
        rtl(d, (35, y + 47), f"{price} USD", 12, FOREST, True, "la")
    rr(d, (20, 625, W - 20, 679), 8, FOREST)
    rtl(d, (W / 2, 654), "تقديم عرض", 15, WHITE, True, "mm")
    return img


def main():
    board = Image.new("RGB", (900, 1900), "#e5e9e5")
    d = ImageDraw.Draw(board)
    rtl(d, (850, 62), "يمني حول العالم", 31, INK, True)
    rtl(d, (850, 101), "معاينة التسليم الأول للتطبيق", 16, MUTED)
    shots = [(onboarding(), 45, 145), (home(), 465, 145), (search(), 45, 1010), (request_detail(), 465, 1010)]
    for shot, x, y in shots:
        shadow = Image.new("RGBA", (W + 20, H + 20), (0, 0, 0, 0))
        sd = ImageDraw.Draw(shadow)
        sd.rounded_rectangle((8, 8, W + 8, H + 8), 18, fill="#17211b25")
        board.paste(shadow, (x - 10, y - 10), shadow)
        mask = Image.new("L", (W, H), 0)
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, W, H), 15, fill=255)
        board.paste(shot, (x, y), mask)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    board.save(OUT, quality=94)
    print(OUT)


if __name__ == "__main__":
    main()
