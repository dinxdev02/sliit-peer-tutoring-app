# Backend and database workflow

The existing Flutter routes use Firebase Authentication, Firestore streams and Firebase Storage. No sample account, rating, booking or conversation is injected by the app. Local seed accounts are explicitly synthetic test fixtures.

## Local Android emulator

For a complete Windows startup (Android emulator already running):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File backend/start-local.ps1
```

This resumes and verifies official Firebase runtime downloads, starts Authentication, Firestore and Storage, seeds missing demo accounts, saves a local data export, and launches Flutter. It imports the saved export on the next startup. Add `-Verify` to run the backend authorization checks before launching; these checks reset the synthetic test fixtures. Download and backend logs are kept in the ignored `.tmp-tools` directory. These records are demo fixtures, not real university student data.

Install Flutter, Node.js 20+, Java 21+ and Firebase CLI (`npm install -g firebase-tools`). Enable Windows Developer Mode if Flutter requests plugin symlink support. Run commands from the repository root in separate terminals:

```powershell
flutter pub get
firebase emulators:start --only auth,firestore,storage --project demo-sliit-peer --export-on-exit emulator-data
```

Once all emulators report ready:

```powershell
node backend/seed.cjs
flutter run -d emulator-5554
```

Debug builds use the Android emulator's `10.0.2.2` host automatically. A different device requires reachable ports and `--dart-define=FIREBASE_EMULATOR_HOST=<host>`. Seed accounts use password `PeerDemo123!`: `student@my.sliit.lk`, `tutor@my.sliit.lk`, and `pending@my.sliit.lk`. The first two fixtures are locally approved; the pending tutor is excluded from discovery. Seeding resets these fixture profiles and sample slots, so do not reseed during a test session. Restart with `--import emulator-data` to restore a previously exported session.

The UI remains on the original onboarding, discovery, profile, request, confirmation, schedule, details, chat and review/report routes. Actual dates, names and counts replace reference-image examples. Empty, pending and error states are intentional. Online confirmation asks the tutor for a Teams link; the app cannot create a university meeting without an integration and university authorization.

## Cloud configuration

The supplied cloud project is `sliit-peer-tutoring`. Its matching Android configuration is present locally at `android/app/google-services.json` and excluded from Git. Enable Email/Password Authentication, create Firestore, and deploy `firestore.rules` and `firestore.indexes.json`. Storage is not required for registration: the cloud startup disables file uploads, while text messages and text-only reports remain available. Run `powershell -NoProfile -ExecutionPolicy Bypass -File backend/run-cloud.ps1` to pass its configuration to Flutter and disable emulator mode. Other developers need their own copy of the project's configuration. Alternatively configure Firebase through FlutterFire or supply all defines:

```powershell
flutter build apk --release --dart-define=USE_FIREBASE_EMULATORS=false --dart-define=FIREBASE_PROJECT_ID=<project> --dart-define=FIREBASE_API_KEY=<key> --dart-define=FIREBASE_APP_ID=<app-id> --dart-define=FIREBASE_SENDER_ID=<sender> --dart-define=FIREBASE_STORAGE_BUCKET=<bucket>
```

The current release signing configuration uses the development key; use the group's signing configuration for distribution. Deploy reviewed `firestore.rules`, `firestore.indexes.json` and `storage.rules` to the selected project before cloud testing. Firebase configuration identifies the project; security comes from authentication and server rules, not hiding client configuration. Never put service-account credentials in Flutter or commit them.

Optional enrollment evidence stays private. Registration without a document stores `verificationEvidence: null`. New registrations remain pending; a trusted administrator must verify enrollment separately and update `users/{uid}.verificationStatus` and the public tutor profile's `verified` field together. The local-only `node backend/approve.cjs <uid>` helper demonstrates approval against emulator fixtures. It cannot approve a cloud account. A production verification process and administrator tooling remain deployment work.

## Data and authorization

| Collection | Contents | Authorized operations |
| --- | --- | --- |
| users | Private profile, enrollment evidence path and guideline acknowledgement | Owner reads/updates profile; trusted admin approves |
| tutorProfiles | Public introduction, modules, year and verification | Owner creates/updates/deletes; verified profiles visible to authenticated users |
| availability | Tutor slots, dates, venue, mode, reservation ID | Tutor creates/updates/deletes unlocked slots; atomic booking locks |
| bookings | Participants, canonical slot, module, notes, lifecycle | Student requests/reschedules; tutor accepts/declines/completes; participants cancel/read |
| reviews | One review per completed booking | Student creates/updates/deletes own review; authenticated readers |
| chats/messages | Private conversation and attachments | Members read/send; sender deletes own message |
| notifications | Booking/message events | Recipient reads/marks read/deletes |
| reports | Confidential immutable submitted report | Reporter creates/reads; administrator reviews |
| users/favorites | Saved tutor IDs | Owner creates/reads/deletes |

Booking transactions read the live slot, reserve it and write the request and notifications together. Cancellation and rescheduling release the old reservation in the same transaction. Notifications are persistent in-app records; background push delivery is not configured. Reviews require a tutor-completed session, not simply a past date. Reports stay immutable after submission to preserve evidence.

## Reproducible validation

```powershell
flutter analyze
flutter test
node --test backend/rules.test.cjs
flutter build apk --debug
```

Backend tests require the emulators to be running and reset synthetic fixtures. They exercise actual server rules using owner and non-owner authentication tokens. Widget tests cover empty-state phone layouts and filter reset, not authenticated network workflows. See `milestone-03-requirements.md` for assessment requirements and human evidence still needed.
