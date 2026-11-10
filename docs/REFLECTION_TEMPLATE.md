# Activity 14 Reflection – <Your Name>

**Device / OS:** <e.g., Pixel 7 emulator, Android 14>
**Permission status:** <granted / denied>
**Valid payload used:**
```json
{
  "notification": { "title": "New promotion", "body": "Switch the screen to the promo asset" },
  "data": { "asset": "promo", "action": "update_ui" }
}
```

## Result rows
| Test | Expected handler/result | Observed result | Pass/Fail/Blocked | Evidence |
|---|---|---|---|---|
| T1 Foreground | onMessage; UI switches to promo | | | |
| T2 Background tap | onMessageOpenedApp; UI promo | | | |
| T3 Cold-start tap | getInitialMessage; UI promo | | | |
| T4 Invalid payload | onMessage; diagnostic shown, title/image unchanged, no crash | | | |

## Response 1 – Setup and payload
(One configuration decision, e.g., I ran `flutterfire configure` for Android only so the
app ID matched my target. `action: update_ui` tells the app to change the UI and `asset`
selects an allow-listed bundled image: `default` or `promo`.)

## Response 2 – Lifecycle and evidence
(T1 used onMessage, T2 onMessageOpenedApp, T3 getInitialMessage; cite evidence. The
onBackgroundMessage handler runs in a separate isolate with no access to widget state,
so it cannot directly update the UI.)

## Response 3 – Validation and next step
(T4: missing/unknown asset -> diagnostic shown, previous title/image preserved, no crash.
One risk/failure you checked. One improvement, e.g., dedupe by an application-level event ID.)

## Limitations / AI assistance
(Single device; delivery not guaranteed; disclose any AI help.)
