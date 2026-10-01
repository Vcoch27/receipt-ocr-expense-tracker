# Product Requirements Document (PRD)
## Mini-Project 3 — Receipt OCR & Expense Tracker

> **Current product direction (October 2026): Smart Expense Capture & Tracker.**
> The original sections preserve the course-required physical receipt workflow.
> This addendum makes payment screenshot import the primary everyday entry
> point while retaining every rubric requirement.

## Product extension — Vietnamese payment screenshots

### Scope and priority

The **course required core** remains physical receipt capture with image_picker,
on-device ML Kit OCR, ReceiptParser merchant/date/total heuristics, mandatory
manual review, SQLite CRUD, Riverpod 2, Material 3, dark mode, and custom
animated donut and weekly bar charts. The signed APK, device demo, GitHub
repository, video, and report remain required.

The **primary Vietnam use case** adds gallery import of a bank or e-wallet
payment success screenshot. The Add Expense entry point presents **Import
Payment Screenshot**, **Scan Receipt**, and **Manual Entry**. Screenshots and
receipts share one on-device OCR service and one review, storage, history, and
analytics flow. No image or OCR text is uploaded to a cloud service.

### Extended pipeline

    Payment screenshot (gallery) ─┐
                                  ├→ ML Kit OCR → source classification
    Physical receipt (camera) ────┘                → source-specific parser
                                                  → normalized ParsedExpense
                                                  → Review & Verification
                                                  → validation → SQLite
                                                  → Riverpod → history/analytics
    Manual entry ─────────────────────────────────→ Review & Verification

ReceiptParser and PaymentScreenshotParser are separate, independently testable
services. Deterministic source classification may combine the user's chosen
capture path with OCR text signals; ambiguous fields remain nullable. The common
expense record stores an input source (receipt, bank screenshot, e-wallet
screenshot, or manual), amount, merchant/recipient, date and optional time,
category, optional provider, transaction reference, note, image path, raw OCR
text, and timestamps. Account numbers are not needed in normal history and
should not be retained or shown there.

The payment parser attempts amount, date/time, recipient, and status first.
It may also extract provider, transaction reference, and payment note when
present. Recognize Vietnamese and English success, pending, and failure
phrases with multiple heuristics. An unsuccessful or pending transaction must
not be silently saved as a completed expense. The unified review form adapts
its fields to the source and requires explicit confirmation for all OCR data.
Unknown values remain editable. A likely duplicate (matching reference or
amount/date/recipient/source) produces a warning during review, not an
automatic block.

All sources contribute to the required category donut and weekly bar charts.
Payment parser tests cover bank and wallet examples, Vietnamese separators,
missing fields, unsuccessful status, noisy OCR, and duplicate metadata.
Receipt parser tests and original course acceptance criteria remain active.

**Course:** Cross-Platform Mobile App Development  
**Platform:** Flutter / Dart  
**Project type:** Mobile application running on physical devices  
**Primary scenario:** Scan Vietnamese cash receipts, extract expense data, verify it, store it locally, and visualize spending.

---

## 1. Product Overview

### 1.1 Product name
**Receipt OCR & Expense Tracker**

### 1.2 Product summary
Receipt OCR & Expense Tracker is a Flutter mobile application designed for VKU students and club managers who frequently handle cash receipts and currently have to manually enter expense information into spreadsheets.

The application captures a receipt image using the device camera, performs on-device OCR with ML Kit Text Recognition, processes the raw OCR output using Dart Regex and heuristic rules, extracts key receipt information such as merchant, transaction date, and total amount, allows the user to review and manually correct OCR errors, then saves the verified record to a local SQLite database. Stored expense data is exposed through application state management and visualized using custom animated charts built with `CustomPainter`.

### 1.3 Core product pipeline

```text
Camera Capture
(image_picker)
      ↓
ML Kit Text Recognition
(On-device OCR)
      ↓
ReceiptParser
(Dart Regex + Heuristics)
      ↓
ParsedReceipt
      ↓
Review & Verification
(Manual correction)
      ↓
Local SQLite Database
(sqflite CRUD)
      ↓
Provider / Riverpod 2 State
      ↓
Expense History + Animated Charts
(CustomPainter)
```

---

## 2. Problem Statement

VKU students and club managers may handle physical cash receipts on a daily basis. Manually entering expense values from receipts into spreadsheets is repetitive, time-consuming, and prone to data-entry errors.

OCR can automate much of this process, but real-world receipts are noisy and inconsistent. Vietnamese receipts may represent currency and amounts using different formats such as:

- `VNĐ`
- `đ`
- `150.000`
- `150,000`
- `150000`

OCR output can also misread merchant names, dates, totals, or individual characters. Therefore, the product must not treat OCR output as automatically correct. A human review and verification step is required before expense data is committed to local storage.

---

## 3. Product Goals

The product must:

1. Capture a receipt image from a physical mobile device.
2. Perform OCR locally on the device using ML Kit Text Recognition.
3. Parse noisy OCR text using Dart Regex and heuristic rules.
4. Extract at minimum:
   - Merchant / store name
   - Transaction date
   - Total amount
5. Present the extracted values to the user for review.
6. Allow manual correction before saving.
7. Persist verified expense records in a local SQLite database.
8. Provide clean state management using Provider or Riverpod 2.
9. Display historical expense data.
10. Visualize expense information using custom animated charts drawn with `CustomPainter`.
11. Use Material 3 UI, responsive layout, and dark mode.
12. Run as a signed release APK on a physical Android device.
13. Include the required demo video, GitHub repository, and short technical PDF report.

---

## 4. Scope

### 4.1 In Scope

The following functionality is explicitly required by the course slides and grading rubric:

- Camera receipt capture
- `image_picker`
- Google ML Kit text recognition
- On-device / offline OCR
- Dart Regex-based parsing
- Heuristic extraction of:
  - Total
  - Date
  - Merchant
- Review and verification screen
- Manual correction before database commit
- Local SQLite persistence using `sqflite`
- CRUD operations
- Receipt photo storage
- Provider or Riverpod 2 architecture
- Material 3 theme
- Dark mode
- Responsive layout
- Custom animated Pie/Donut category chart
- Weekly bar chart
- `CustomPainter`
- Signed release APK
- Demo video
- Public GitHub repository
- Technical PDF report

### 4.2 Out of Scope / Not Required by the Slides

The source slides do not require the following features, so they should be treated as optional enhancements rather than mandatory project scope:

- Cloud synchronization
- User accounts / authentication
- Multi-device synchronization
- Online OCR service
- Web dashboard
- Bank account integration
- Export to accounting software
- Automatic cloud backup
- Collaborative expense sharing
- Push notifications

If any of these are added, they should not reduce the quality or completeness of the required rubric items.

---

## 5. Target Users

### 5.1 Primary users

**VKU students**
- Need to quickly record personal or project-related expenses.
- May receive many small paper receipts.
- Prefer faster capture instead of manual typing.

**VKU club managers**
- Need to keep records of club expenses.
- May need to review expense history later.
- Benefit from categorized visual summaries.

### 5.2 User needs

Users need to:

- Capture expense data quickly.
- Avoid manually typing all receipt information.
- Correct OCR mistakes before saving.
- Retrieve previously scanned receipts.
- Understand spending through charts.
- Use the application without requiring an internet connection for OCR and local data storage.

---

## 6. User Journey

### 6.1 Primary happy path

```text
Open app
  ↓
Tap Scan Receipt
  ↓
Capture / select receipt image
  ↓
Run ML Kit OCR
  ↓
Receive raw OCR text
  ↓
Parse merchant, date, and total
  ↓
Open Review & Verification Screen
  ↓
User verifies / edits values
  ↓
Validate form
  ↓
Save to SQLite
  ↓
Update application state
  ↓
Refresh expense history
  ↓
Update dashboard charts
```

### 6.2 OCR failure path

```text
Capture receipt
  ↓
OCR returns incomplete/noisy text
  ↓
Regex cannot confidently extract a field
  ↓
Field remains empty or requires correction
  ↓
User manually enters value
  ↓
Validation passes
  ↓
Save verified record
```

The slides explicitly require manual review because OCR output is raw and noisy.

---

## 7. Functional Requirements

### FR-01 — Receipt Image Capture

**Description:**  
The user must be able to capture or obtain a receipt image from a mobile device using `image_picker`.

**Requirements:**
- Provide a clear scan/capture action.
- Pass the captured image to the OCR service.
- Retain or associate the receipt photo with the stored expense record where implemented.

**Acceptance criteria:**
- A user can initiate receipt capture from the app.
- The captured image can be processed by ML Kit.
- The workflow runs on a physical Android device.

---

### FR-02 — On-Device OCR

**Description:**  
The app must use ML Kit Text Recognition to convert the receipt image into raw text.

**Requirements:**
- OCR executes on-device.
- Raw recognized text is returned to the parsing layer.
- OCR is not treated as guaranteed correct.

**Acceptance criteria:**
- A real receipt can be scanned in the demo.
- OCR output is available without requiring a cloud OCR workflow.
- Parsed data can be traced back to recognized text.

---

### FR-03 — Receipt Parser

**Description:**  
The app must contain a Dart parsing layer such as `ReceiptParser` using Regex and heuristic logic.

**Required extracted fields:**
- Total amount
- Date
- Merchant header / merchant name

**Total amount heuristics should account for receipt keywords such as:**
- `total`
- `tong tien`
- `thanh toan`
- `cong tien`
- `amount due`

**Formatting considerations:**
- `150.000`
- `150,000`
- `150000`
- `VNĐ`
- `đ`

**Acceptance criteria:**
- The parser attempts to extract the required fields from OCR text.
- If no valid value is found, the app can fall back to manual entry.
- Amount normalization supports common dot/comma formatting found in Vietnamese receipts.

---

### FR-04 — Review & Verification Screen

**Description:**  
Every scanned receipt must pass through a review step before committing data to SQLite.

**Requirements:**
- Display parsed merchant.
- Display parsed date.
- Display parsed total amount.
- Allow the user to manually edit incorrect values.
- Do not save the final record until the user confirms.

**Acceptance criteria:**
- User can inspect OCR-derived values.
- User can correct OCR mistakes.
- Invalid or missing values can be fixed manually.
- Confirmed values are the values stored in SQLite.

---

### FR-05 — Form Validation

**Description:**  
The review form must validate user input.

**Requirements based on the Week 8 form patterns:**
- Use `Form`.
- Use `GlobalKey<FormState>`.
- Use `TextEditingController`.
- Use `TextFormField`.
- Merchant must not be empty.
- Amount must be a valid positive number.
- Controllers must be disposed correctly.

**Acceptance criteria:**
- Invalid merchant input displays an error.
- Invalid amount input displays an error.
- The record is only saved after validation succeeds.

---

### FR-06 — Local SQLite Persistence

**Description:**  
Verified expense records must be stored persistently using `sqflite`.

**Required database capabilities:**
- Create
- Read
- Update
- Delete

**Acceptance criteria:**
- Saved receipts remain available after app restart.
- Expense history can be loaded from SQLite.
- A stored expense can be modified or deleted.
- Stored data can be consumed by the application state layer.

---

### FR-07 — Expense History

**Description:**  
The app must provide a view of previously stored expenses.

**Requirements:**
- Display expense records from SQLite.
- Use efficient list rendering such as `ListView.builder`.
- Each record should show sufficient information to identify the transaction.

**Recommended minimum visible fields:**
- Merchant
- Date
- Amount

**Acceptance criteria:**
- Records saved to SQLite appear in history.
- Long lists are rendered efficiently.
- User can identify individual expense records.

---

### FR-08 — State Management

**Description:**  
The application must use a clean Provider or Riverpod 2 architecture.

**Preferred source-aligned option:**  
Riverpod 2 with a Notifier/Provider structure.

**Responsibilities:**
- Expose expense state to the UI.
- React to database updates.
- Trigger UI refreshes when expense data changes.
- Avoid unnecessary large rebuilds.

**Acceptance criteria:**
- Business/state logic is separated from presentation widgets.
- Expense changes are reflected reactively in the UI.
- State architecture is clear in the repository structure.

---

### FR-09 — Expense Visualization

**Description:**  
The app must visualize expense data using custom drawing rather than relying only on an external chart component.

**Required charts:**
1. Animated Pie/Donut category chart
2. Weekly bar chart

**Technology:**
- `CustomPainter`
- Flutter Canvas APIs
- Animation where applicable

**Acceptance criteria:**
- Donut/Pie chart is custom drawn.
- Weekly bar chart is custom drawn.
- Charts reflect stored expense data.
- Animation is visible in the demo.

---

### FR-10 — Material 3 UI

**Description:**  
The application must use a polished Material 3 design.

**Requirements:**
- Material 3 theme
- Responsive layout
- Dark mode
- Clear review/correction UI
- Reusable UI components

**Acceptance criteria:**
- Light and dark modes are demonstrable.
- Layout works correctly on the target mobile device.
- Core screens follow one consistent visual system.

---

## 8. Suggested Screen Structure

The slides do not prescribe an exact screen list, but the following structure directly supports the required workflow.

### 8.1 Dashboard / Home
Purpose:
- Entry point
- Show summary
- Open scanner
- Show recent expenses
- Access charts

### 8.2 Receipt Scanner
Purpose:
- Capture/select image
- Run OCR
- Show processing/loading state

### 8.3 Review & Verification
Purpose:
- Display OCR results
- Edit merchant
- Edit date
- Edit total
- Confirm or cancel

### 8.4 Expense History
Purpose:
- Read persisted records
- View previously scanned receipts
- Support update/delete operations

### 8.5 Expense Detail / Edit
Purpose:
- Display one stored expense
- Edit the stored data if needed

### 8.6 Analytics
Purpose:
- Animated category Pie/Donut chart
- Weekly bar chart

---

## 9. Navigation

A source-aligned Flutter implementation may use `GoRouter`.

Suggested routes:

```text
/
  → Dashboard

/scan
  → Receipt Scanner

/review
  → Review & Verification

/expenses
  → Expense History

/expense/:id
  → Expense Detail

/analytics
  → Analytics
```

For persistent bottom navigation, `ShellRoute` may contain:

```text
Dashboard
Scanner
Analytics
```

This navigation structure is an implementation proposal based on the GoRouter material in Week 8; the slides do not mandate these exact route names.

---

## 10. Data Model

The slides require storage of OCR-derived expense data and receipt photo storage, but they do not define an exact database schema. The following schema is a practical implementation proposal.

### ExpenseItem

```text
id
merchant
amount
date
category
imagePath
rawOcrText
createdAt
updatedAt
```

### Field descriptions

| Field | Type | Purpose |
|---|---|---|
| `id` | String / Integer | Unique record identifier |
| `merchant` | String | Merchant/store name |
| `amount` | Double | Verified total expense |
| `date` | DateTime | Transaction date |
| `category` | String | Used for category chart |
| `imagePath` | String? | Local receipt photo reference |
| `rawOcrText` | String? | OCR output for debugging/review |
| `createdAt` | DateTime | Record creation time |
| `updatedAt` | DateTime | Last modification |

The `category` field is proposed because the rubric requires a category Pie/Donut chart.

---

## 11. Application Architecture

Recommended source-aligned project structure:

```text
lib/
├── core/
├── models/
│   ├── expense_item.dart
│   └── parsed_receipt.dart
├── services/
│   ├── ocr_service.dart
│   ├── receipt_parser.dart
│   └── expense_database.dart
├── state/
│   └── expense_provider.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── scanner_screen.dart
│   ├── review_screen.dart
│   ├── expense_history_screen.dart
│   ├── expense_detail_screen.dart
│   └── analytics_screen.dart
├── widgets/
│   ├── expense_summary_card.dart
│   ├── donut_chart.dart
│   └── weekly_bar_chart.dart
├── routing/
│   └── app_router.dart
└── main.dart
```

The Week 8 deliverables checklist explicitly expects a clean repository architecture including folders such as:

```text
core/
models/
services/
state/
widgets/
screens/
```

---

## 12. Key Technical Components

### 12.1 OCR
Package / technology:
- `google_mlkit_text_recognition`

Responsibility:
- Convert receipt image into raw text.

### 12.2 Camera / Image Input
Package:
- `image_picker`

Responsibility:
- Acquire receipt image.

### 12.3 Parser
Technology:
- Dart
- `RegExp`

Responsibility:
- Extract structured values from OCR text.

### 12.4 State Management
Allowed:
- Provider
- Riverpod 2

Preferred in the Week 8 material:
- Riverpod 2

### 12.5 Local Database
Package:
- `sqflite`

Responsibility:
- Persistent CRUD.

### 12.6 Routing
Suggested from Week 8:
- `go_router`

### 12.7 Visualization
Technology:
- `CustomPainter`
- `Canvas`
- `AnimationController`

---

## 13. Regex / Heuristic Requirements

The parser must be tolerant of real-world receipt variation.

Example source-aligned approach:

```dart
final keywordPattern = RegExp(
  r'(total|tong tien|thanh toan|cong tien|amount due)',
  caseSensitive: false,
);

final numberPattern = RegExp(
  r'[\d]{1,3}(?:[.,]\d{3})*(?:\.\d{2})?'
);
```

Processing concept:

```text
Split OCR into lines
  ↓
Find line containing total-related keyword
  ↓
Find numeric values on that line
  ↓
Take suitable candidate
  ↓
Remove thousand separators
  ↓
Convert to numeric value
  ↓
If parsing fails → manual entry
```

The exact heuristic may be improved during implementation, but the fallback to manual review must remain.

---

## 14. Non-Functional Requirements

### 14.1 Performance
- Avoid expensive parsing work inside frequently rebuilt `build()` methods.
- Use efficient list rendering.
- Limit unnecessary widget rebuilds.
- Custom animations should remain smooth on the target physical device.

### 14.2 Reliability
- OCR errors must not silently become final database data.
- Manual verification is required.
- Form inputs must be validated.
- Database records must persist after restart.

### 14.3 Offline Capability
The core pipeline is designed around:
- On-device OCR
- Local SQLite storage

Therefore, the main scanning and storage workflow should not depend on a remote cloud service.

### 14.4 Maintainability
- Separate UI, state, models, services, and database code.
- Keep parser logic outside presentation widgets.
- Dispose controllers, FocusNodes, animation controllers, and listeners correctly.

### 14.5 Usability
- Scanning should require minimal steps.
- OCR results must be easy to inspect.
- Correction fields must be understandable.
- Successful save should provide user feedback.

---

## 15. Error Handling

The app should handle at minimum:

| Case | Expected behavior |
|---|---|
| User cancels image picker | Return safely to previous screen |
| OCR returns no text | Show review/manual-entry path or clear error state |
| Total cannot be parsed | Allow manual entry |
| Merchant cannot be detected | Allow manual entry |
| Date cannot be detected | Allow correction/manual entry |
| Invalid amount | Block save and show validation error |
| SQLite write fails | Show error and do not report successful save |
| Chart has no expense data | Show meaningful empty state |
| Receipt image unavailable | Keep textual record usable where possible |

Some detailed UI behavior above is proposed for completeness; the slides mainly require the OCR-review-save pipeline and manual correction fallback.

---

## 16. UX Requirements

### Required
- Material 3
- Dark mode
- Responsive layout
- Review & manual correction flow

### Recommended
- Loading indicator during OCR
- Clear scan button
- OCR confidence should not be visually implied unless actual confidence data is available
- Highlight fields that need manual correction
- Confirmation feedback after successful save
- Empty-state UI for no saved expenses
- Accessible typography and touch targets

---

## 17. Analytics / Charts

### 17.1 Category Donut Chart
Purpose:
- Show proportion of expense totals by category.

Implementation:
- `CustomPainter`
- `drawArc`
- Animated progress from `0.0` to `1.0`

### 17.2 Weekly Bar Chart
Purpose:
- Show spending totals across days or weekly periods.

Implementation:
- Custom Canvas bars
- Data aggregated from local expense records

### 17.3 Chart acceptance criteria
- Uses stored application data.
- Updates after a new expense is saved.
- Custom-painted rather than only embedded from a third-party chart package.
- Demonstrated in the final demo video.

---

## 18. Definition of Done

The project is considered functionally complete when:

- [ ] Receipt image can be captured on a physical device.
- [ ] ML Kit OCR successfully runs.
- [ ] Raw OCR text is parsed.
- [ ] Merchant is extracted or manually entered.
- [ ] Date is extracted or manually entered.
- [ ] Total is extracted or manually entered.
- [ ] Review & Verification Screen is present.
- [ ] User can correct OCR mistakes.
- [ ] Validation blocks invalid values.
- [ ] Verified expense is stored in SQLite.
- [ ] SQLite CRUD is implemented.
- [ ] Expense history is displayed.
- [ ] Provider or Riverpod 2 manages app state.
- [ ] Pie/Donut chart is custom drawn.
- [ ] Weekly bar chart is custom drawn.
- [ ] Chart animation is implemented.
- [ ] Material 3 theme is applied.
- [ ] Dark mode is supported.
- [ ] Responsive layout is supported.
- [ ] Receipt photo storage is implemented.
- [ ] Signed release APK is generated.
- [ ] App is tested on a physical Android device.
- [ ] Demo video is completed.
- [ ] Public GitHub repository is clean.
- [ ] README is comprehensive.
- [ ] Technical PDF report is completed.

---

## 19. Grading Rubric Mapping

| Component | Required capabilities | Points |
|---|---|---:|
| On-Device OCR & Heuristics | Camera capture, ML Kit text recognition, Regex extraction of Total, Date, Merchant | 3.5 |
| Custom Canvas Visualization | Animated Pie/Donut category chart and weekly bar chart using `CustomPainter` | 2.5 |
| State Management & DB | Clean Provider/Riverpod 2 architecture, persistent `sqflite` CRUD, receipt photo storage | 2.0 |
| UI/UX Polish | Material 3, dark mode, responsive layout, review/manual correction | 1.0 |
| Deliverables & Report | Signed APK, demo video, clean GitHub repository, 2–4 page technical PDF | 1.0 |
| **Total** |  | **10.0** |

### Priority by grading weight

```text
OCR + Heuristics           35%
Custom Charts              25%
State + Database           20%
UI/UX                      10%
Deliverables + Report      10%
```

Implementation effort should prioritize the required OCR pipeline and custom visualization before optional features.

---

## 20. Final Deliverables

### 20.1 Signed Release APK
Required:
- `app-release.apk`
- Downloadable through GitHub Releases or Google Drive
- Tested on a physical Android device

### 20.2 Demo Video
Length:
- 2–3 minutes

Must demonstrate:
1. Live camera scanning of a real receipt
2. OCR recognition
3. Regex parsing
4. Review / correction
5. Save confirmation
6. Animated donut chart updating

### 20.3 GitHub Repository
Required:
- Public repository
- Clean commits
- Clean architecture
- Comprehensive `README.md`

Expected structure includes:
- `core/`
- `models/`
- `services/`
- `state/`
- `widgets/`
- `screens/`

### 20.4 Technical Report
Length:
- 2–4 pages

Required content:
- Architecture diagram
- OCR regex table
- Screenshots of light mode
- Screenshots of dark mode
- Known limitations

---

## 21. Suggested Development Milestones

The exact sprint breakdown is not specified by the source slides. The following is a practical implementation plan.

### Milestone 1 — Flutter Foundation
- Create Flutter project
- Configure Material 3
- Establish folder architecture
- Set up routing
- Create basic screens

### Milestone 2 — OCR Pipeline
- Integrate `image_picker`
- Integrate ML Kit Text Recognition
- Capture and display OCR output

### Milestone 3 — Parser
- Implement `ReceiptParser`
- Extract total
- Extract merchant
- Extract date
- Test Vietnamese receipt formats

### Milestone 4 — Review Workflow
- Build Review & Verification Screen
- Add `Form`
- Add validation
- Allow manual corrections

### Milestone 5 — SQLite
- Create local database
- Implement CRUD
- Persist receipt history
- Associate receipt photo where applicable

### Milestone 6 — State Management
- Integrate Provider or Riverpod 2
- Connect database state to UI
- Update history reactively

### Milestone 7 — Analytics
- Build animated Donut/Pie chart
- Build weekly bar chart
- Connect charts to persisted expense data

### Milestone 8 — Polish & Release
- Dark mode
- Responsive layout
- Error/empty/loading states
- Physical device testing
- Release APK
- Demo video
- README
- Technical report

---

## 22. Main Acceptance Test Scenario

**Given**
- The application is installed on a physical Android device.
- No prior expense is required.

**When**
1. The user opens the app.
2. The user scans a real receipt.
3. ML Kit recognizes text from the receipt.
4. The parser extracts merchant, date, and total.
5. The Review & Verification Screen opens.
6. The user corrects any incorrect OCR value.
7. The user confirms the receipt.
8. The app validates the form.
9. The app stores the expense in SQLite.

**Then**
- The expense appears in history.
- Data remains after restarting the app.
- Application state reflects the new expense.
- Analytics are recalculated.
- The animated chart reflects the updated data.

---

## 23. Product Outcome

The final outcome of Mini-Project 3 is a production-oriented Flutter mobile application that demonstrates the complete flow from physical-world input to structured local data and visualization: capturing a receipt with the device camera, performing on-device OCR with ML Kit, applying Dart Regex and heuristic parsing to extract the merchant, date, and total amount, allowing the user to review and manually correct noisy OCR results, validating the corrected values, persisting verified expense records and receipt information with SQLite CRUD, managing application state cleanly with Provider or Riverpod 2, and presenting expense history through a polished Material 3 responsive interface with dark mode and custom animated Pie/Donut and weekly bar charts built using `CustomPainter`. The project is completed with a signed release APK tested on a physical Android device, a 2–3 minute demonstration video, a clean public GitHub repository, and a 2–4 page technical report documenting the architecture, OCR regex rules, UI screenshots, and known limitations.

---

## 24. Source Basis and Assumptions

This PRD is based on the provided Week 7 and Week 8 course slides for Mini-Project 3.

Items explicitly required by the slides are treated as mandatory requirements.

Where the slides do not prescribe an exact implementation detail — for example exact screen names, route paths, database column names, or sprint breakdown — this PRD labels or treats those details as implementation proposals intended to make the project executable without changing the required outcome.
