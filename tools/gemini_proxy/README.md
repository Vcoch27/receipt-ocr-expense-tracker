# Optional Gemini second opinion

The app still performs required ML Kit OCR and heuristic parsing on device. Gemini is called only when the user taps **Read again with AI** on the review form and confirms that the selected image will be uploaded. Its output is a suggestion; the user must explicitly apply it, review all fields, and confirm saving. The proxy never writes an expense or stores an image.

## Local Samsung setup

1. Create a Gemini API key in your own Google AI Studio project. Check the model's free-tier availability, quota and data-handling terms in your project. Do not put the key in Flutter code, `--dart-define`, Git, screenshots or chat.
2. In PowerShell, set a temporary environment variable: `$env:GEMINI_API_KEY = Read-Host -MaskInput 'Gemini API key'` and run `node tools/gemini_proxy/server.mjs`. Requires Node 18+ and uses only built-in modules.
3. In another terminal, run `adb reverse tcp:8787 tcp:8787` and `flutter run -d R9JN409P9RJ --dart-define=AI_PROXY_URL=http://127.0.0.1:8787/analyze`.

The proxy listens on loopback only. A physical device reaches it through ADB reverse while connected by USB. The Flutter button is hidden if `AI_PROXY_URL` is absent. No Gemini request occurs during ordinary OCR or while viewing an expense.

For a deployed build, use an HTTPS proxy with server-side secret storage, authentication, per-user quotas and rate limiting before exposing it to the Internet. Do not publicly deploy this local development server. Configure the app's `AI_PROXY_URL` to the authenticated proxy URL. The free Gemini API tier has quotas and may use submitted data under different terms from paid usage; read Google's current pricing and terms before sending sensitive receipts or bank screenshots.
