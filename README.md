# Cloud Courier – Flutter FCM (Activity 14)

## 1. Prerequisites
- Flutter SDK, `flutter doctor` clean
- Node.js + Firebase CLI:  `npm i -g firebase-tools` then `firebase login`
- FlutterFire CLI:  `dart pub global activate flutterfire_cli`
- Android emulator WITH Google Play services (or a real phone). Work on ONE platform only.

## 2. Create platform folders (run inside this folder)
```
flutter create . --org com.yourname --project-name cloud_courier
flutter pub get
```
(This adds android/ and ios/ without overwriting lib/ or pubspec.yaml.)

## 3. Connect Firebase
```
flutterfire configure
```
Pick/create a Firebase project, select ONLY your target platform (e.g. android).
This overwrites lib/firebase_options.dart and adds google-services.json.

## 4. Android extras
Edit android/app/src/main/AndroidManifest.xml, add above `<application>`:
```
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```
If the build complains about minSdk, set `minSdk = 23` in android/app/build.gradle(.kts).
If it complains about google-services, make sure the `com.google.gms.google-services`
plugin is applied (flutterfire configure normally does this).

## 5. Run
```
flutter run
```
Allow notifications when prompted. Copy the FCM token (button in app).

## 6. Send test messages
Firebase Console -> Engage -> Messaging -> Create (New campaign) -> Firebase Notification messages
-> Title "New promotion", Body anything -> "Send test message" -> paste token.
Under Additional options -> Custom data add:
- `asset` = `promo`
- `action` = `update_ui`

## 7. The four tests (record screen once or take 4 screenshots)
| Test | What to do | Expected "Last handler" |
|---|---|---|
| T1 Foreground | App open, send valid payload | `onMessage`, image -> promo |
| T2 Background | Press Home, send, TAP notification | `onMessageOpenedApp` |
| T3 Cold start | Swipe app away from recents (NOT force-stop), send, TAP notification | `getInitialMessage` |
| T4 Invalid | App open, send with `asset` = `unknown` (or omit asset) | `onMessage`, red diagnostic card, title/image unchanged |

Tip: reset to default before T2/T3 isn't required; use the receipt count / message ID
to prove each event is fresh. Redact the token in evidence.

## 8. Submit
1. Push to a GitHub repo (do NOT commit secrets you don't want public; google-services.json is OK for coursework but check your instructor's policy).
   `git init && git add . && git commit -m "Activity 14" && git remote add origin <url> && git push -u origin main`
2. Fill in docs/REFLECTION_TEMPLATE.md (150-250 words across 3 responses).
3. Upload repo link + evidence + reflection to the LMS.

## Troubleshooting
- No token / no notifications: use an emulator image with Google Play, check notification permission.
- iOS: needs APNs key uploaded in Firebase Console + Push Notifications & Background Modes capabilities; real device recommended.
- "Run flutterfire configure" error at startup: step 3 not done.
- Force-stopped app (Android Settings) won't receive messages until reopened.
