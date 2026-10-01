# 2-3 minute demonstration flow

Use a physical Android device, a real Vietnamese paper receipt, and a payment
success screenshot. Record the device screen and camera view clearly enough
that OCR recognition and manual correction are visible.

| Time | Action | Evidence to show |
|---|---|---|
| 0:00-0:15 | Open Smart Expense Capture; show empty or existing dashboard, theme menu | Material 3 home and dark mode |
| 0:15-0:35 | Add Expense, Scan Receipt, photograph a real receipt | Physical camera and image_picker path |
| 0:35-0:55 | Wait for on-device OCR; open recognized text | ML Kit and raw OCR trace |
| 0:55-1:20 | Review merchant, date, total; correct one field | Mandatory verification and Regex/heuristic fallback |
| 1:20-1:35 | Confirm and save; open history/detail | SQLite persistence and saved photo |
| 1:35-1:50 | Open Insights | Animated CustomPainter donut and weekly bars |
| 1:50-2:20 | Add Expense, Import Payment Screenshot, select bank/wallet image | Primary Vietnam product path |
| 2:20-2:45 | Review status, recipient, amount/time/provider; correct and save | Unified review, source label, updated analytics |

Before recording, verify the device date, receipt legibility, permission prompts,
and release APK installation. Restart the app once to show that SQLite records
survive process termination. Do not show unmasked account information in the
published video.
