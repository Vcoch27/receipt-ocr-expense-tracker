"""Build the three-page course technical report after Android screenshots exist."""

from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    Flowable,
    Image,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "output" / "pdf" / "smart_expense_technical_report.pdf"
LIGHT = ROOT / "docs" / "screenshots" / "light-home.png"
DARK = ROOT / "docs" / "screenshots" / "dark-home.png"

pdfmetrics.registerFont(TTFont("Arial", r"C:\Windows\Fonts\arial.ttf"))
pdfmetrics.registerFont(TTFont("Arial-Bold", r"C:\Windows\Fonts\arialbd.ttf"))

NAVY = colors.HexColor("#164A7B")
GREEN = colors.HexColor("#287A56")
INK = colors.HexColor("#14212B")
MUTED = colors.HexColor("#51616B")
PALE = colors.HexColor("#EEF4F6")
LINE = colors.HexColor("#D9E3E8")

TITLE = ParagraphStyle(
    "title", fontName="Arial-Bold", fontSize=20, leading=25,
    textColor=INK, spaceAfter=10,
)
H1 = ParagraphStyle(
    "h1", fontName="Arial-Bold", fontSize=13, leading=17,
    textColor=NAVY, spaceBefore=11, spaceAfter=7,
)
BODY = ParagraphStyle(
    "body", fontName="Arial", fontSize=9, leading=13.5,
    textColor=INK, spaceAfter=7,
)
SMALL = ParagraphStyle(
    "small", fontName="Arial", fontSize=8, leading=11,
    textColor=MUTED, spaceAfter=5,
)
CELL = ParagraphStyle(
    "cell", fontName="Arial", fontSize=8, leading=11, textColor=INK,
)
CELL_HEAD = ParagraphStyle(
    "cellhead", parent=CELL, fontName="Arial-Bold", textColor=colors.white,
)
CAPTION = ParagraphStyle(
    "caption", fontName="Arial", fontSize=8.5, leading=12,
    textColor=MUTED, alignment=TA_CENTER,
)


def p(text: str, style=BODY):
    return Paragraph(text, style)


def table(rows, widths):
    cells = [[p(str(value), CELL_HEAD if row == 0 else CELL)
              for value in values] for row, values in enumerate(rows)]
    result = Table(cells, colWidths=widths, repeatRows=1, hAlign="LEFT")
    result.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), NAVY),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, PALE]),
        ("LINEBELOW", (0, -1), (-1, -1), 0.5, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 9),
        ("RIGHTPADDING", (0, 0), (-1, -1), 9),
        ("TOPPADDING", (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
    ]))
    return result


class ArchitectureDiagram(Flowable):
    def __init__(self):
        super().__init__()
        self.width = 506
        self.height = 206

    def draw(self):
        c = self.canv

        def box(x, y, width, label, fill=PALE):
            c.setFillColor(fill)
            c.setStrokeColor(LINE)
            c.roundRect(x, y, width, 32, 8, fill=1, stroke=1)
            c.setFillColor(INK)
            c.setFont("Arial-Bold", 8.2)
            c.drawCentredString(x + width / 2, y + 12, label)

        def arrow(x1, y1, x2, y2):
            c.setStrokeColor(NAVY)
            c.setFillColor(NAVY)
            c.setLineWidth(1.2)
            c.line(x1, y1, x2, y2)
            c.line(x2, y2, x2 - 3, y2 + 5)
            c.line(x2, y2, x2 + 3, y2 + 5)

        box(12, 169, 208, "Payment screenshot - primary")
        box(286, 169, 208, "Physical receipt - course core")
        box(153, 126, 200, "Shared on-device ML Kit OCR")
        box(12, 82, 208, "PaymentScreenshotParser")
        box(286, 82, 208, "ReceiptParser")
        box(153, 39, 200, "Unified Review & Verification",
            colors.HexColor("#DFEEE5"))
        c.setFillColor(NAVY)
        c.setFont("Arial", 8)
        c.drawCentredString(253, 8, "Validation  →  SQLite  →  Riverpod  →  History + CustomPainter")
        arrow(116, 169, 206, 158)
        arrow(390, 169, 300, 158)
        arrow(253, 126, 253, 115)
        arrow(115, 82, 205, 71)
        arrow(391, 82, 301, 71)
        arrow(253, 39, 253, 29)


def image_fit(path: Path, max_width: float, max_height: float):
    image = ImageReader(str(path))
    width, height = image.getSize()
    scale = min(max_width / width, max_height / height)
    return Image(str(path), width=width * scale, height=height * scale)


def decorate(canvas, document):
    canvas.saveState()
    width, _ = A4
    canvas.setStrokeColor(LINE)
    canvas.line(44, 36, width - 44, 36)
    canvas.setFont("Arial", 8)
    canvas.setFillColor(MUTED)
    canvas.drawString(44, 24, "VKU Cross-Platform Mobile App Development · Mini-Project 3")
    canvas.drawRightString(width - 44, 24, f"{document.page} / 3")
    canvas.restoreState()


def main():
    for path in (LIGHT, DARK):
        if not path.exists():
            raise SystemExit(f"Capture the Android screenshot first: {path}")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    document = SimpleDocTemplate(
        str(OUT), pagesize=A4, leftMargin=44, rightMargin=44,
        topMargin=42, bottomMargin=48,
    )
    width = A4[0] - 88
    story = []

    # Page 1 - overview and architecture
    story.append(p("Smart Expense Capture &amp; Tracker", TITLE))
    story.append(p(
        "Technical report · Mini-Project 3 · Flutter / Dart · October 2026",
        SMALL,
    ))
    story.append(p(
        "Vietnamese users often keep a bank or e-wallet payment screenshot rather "
        "than a paper receipt. The app therefore offers screenshot import as its "
        "primary entry, while retaining the course-required physical receipt "
        "camera and OCR workflow. Both inputs use on-device recognition and "
        "require human verification before local storage."
    ))
    story.append(p("Architecture", H1))
    story.append(ArchitectureDiagram())
    story.append(p("Course core and product extension", H1))
    story.append(table([
        ["Course required core", "Product extension"],
        ["Camera/gallery receipt, ML Kit OCR, receipt total/date/merchant "
         "heuristics, review, SQLite CRUD, Riverpod 2, custom charts.",
         "Bank and e-wallet screenshot import, payment-specific parser, "
         "status, source label, optional provider/reference, duplicate warning."],
    ], [width / 2, width / 2]))
    story.append(Spacer(1, 12))
    story.append(p(
        "Design: Material 3, a restrained blue/green palette, solid surfaces, "
        "48 dp touch targets, light/dark themes, an original receipt/check "
        "brand mark, Vietnamese-first and English UI, and one review form "
        "adapted to the input source.", SMALL,
    ))
    story.append(PageBreak())

    # Page 2 - algorithm, data, verification, limitations
    story.append(p("OCR heuristics and persistence", TITLE))
    story.append(p(
        "Recognition uses google_mlkit_text_recognition with the Latin model. "
        "The parsers apply Dart RegExp and ordered rules; uncertain fields stay "
        "blank. No OCR value is committed directly."
    ))
    story.append(table([
        ["Field", "Detection rule", "Review fallback"],
        ["Receipt total", "Weighted total/tổng tiền/thanh toán/cộng tiền/"
         "amount due line; adjacent amount line; VND grouping.", "Blank amount"],
        ["Receipt merchant", "First plausible header; reject invoice, address, "
         "phone and date labels.", "Blank merchant"],
        ["Date/time", "Strict dd/MM/yyyy or yyyy-MM-dd, plus HH:mm for "
         "payments; reject impossible dates.", "Editable date/time"],
        ["Payment amount", "Prefer số tiền/amount and currency-bearing lines; "
         "normalize 150000, 150.000, 150,000.", "Blank amount"],
        ["Recipient/status", "Labelled recipient or cautious post-date name; "
         "detect failed/pending before success phrases.",
         "Edit recipient; require success"],
        ["Transfer note", "Labelled content, transfer phrase, or text after "
         "a destination account number; never copy the number.",
         "Optional editable note"],
        ["Duplicate", "Reference match, or same source + amount + date + "
         "recipient.", "Warn; user may save anyway"],
    ], [width * .2, width * .58, width * .22]))
    story.append(p("Data and state", H1))
    story.append(p(
        "SQLite stores integer VND amounts, date/time, category, source, "
        "merchant/recipient, optional status/provider/reference/note, image "
        "path, and timestamps. Version 2 adds payment columns with an additive "
        "migration. ExpenseDatabase owns SQL; a Riverpod 2 AsyncNotifier "
        "refreshes history and analytics after each successful mutation."
    ))
    story.append(p("Privacy, testing, and limits", H1))
    story.append(p(
        "OCR and image processing stay on-device. Payment OCR text is visible "
        "during review but not persisted because it may contain account "
        "numbers; screenshots remain in app-owned storage. Unit/widget tests "
        "cover receipt and payment parsing, form correction/validation, SQLite "
        "CRUD, duplicate detection, and aggregation. The Android integration "
        "test mocks picker/ML Kit while exercising the real parsers and UI."
    ))
    story.append(p(
        "Limitations: noisy or handwritten inputs need correction; ambiguous "
        "VND decimals are not guessed; bank layouts vary; duplicate matching "
        "is advisory. Release OCR was exercised with three payment screenshots "
        "on a Samsung Android phone; camera receipt quality still needs a "
        "real paper receipt. iOS build validation "
        "requires macOS and Xcode.", SMALL,
    ))
    story.append(PageBreak())

    # Page 3 - screenshots and demo evidence
    story.append(p("Material 3 interface", TITLE))
    story.append(p(
        "Screenshots below were captured from the Android build before the "
        "Vietnamese labels and launcher icon were added. The same navigation "
        "and review hierarchy remains in the current release."
    ))
    shot_table = Table([[
        image_fit(LIGHT, 218, 432),
        image_fit(DARK, 218, 432),
    ]], colWidths=[width / 2, width / 2], hAlign="CENTER")
    shot_table.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("LEFTPADDING", (0, 0), (-1, -1), 5),
        ("RIGHTPADDING", (0, 0), (-1, -1), 5),
    ]))
    story.append(shot_table)
    story.append(Spacer(1, 6))
    story.append(Table([[
        p("Light mode", CAPTION), p("Dark mode", CAPTION),
    ]], colWidths=[width / 2, width / 2]))
    story.append(p("Demo sequence", H1))
    story.append(p(
        "Open app → scan a real receipt → show OCR text and Regex-derived "
        "fields → correct in Review &amp; Verification → save → history → "
        "animated category donut and weekly bars. Then import a bank or "
        "wallet screenshot, verify status/recipient/amount, and show the "
        "combined analytics update."
    ))
    story.append(p(
        "Implementation references: repository PRD and README; Flutter "
        "documentation; google_mlkit_text_recognition and image_picker "
        "package documentation on pub.dev.", SMALL,
    ))

    document.build(story, onFirstPage=decorate, onLaterPages=decorate)
    print(OUT)


if __name__ == "__main__":
    main()
