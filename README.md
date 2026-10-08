# SLIIT Peer — Peer-to-Peer Tutoring Marketplace

IT3060 Human Computer Interaction — Milestone 03
Group WE_134, SLIIT

## Project Description
A free, peer-to-peer tutoring mobile app for SLIIT university students, allowing tutees to discover verified peer tutors by module, book sessions, message tutors, and leave reviews — built to address the discovery, trust, scheduling, and communication pain points identified in Milestone 01's user research.

## Tech Stack
- **Frontend:** Flutter
- **Backend/Database:** Firebase (Firestore)
- **Authentication:** Firebase Authentication (Email/Password)
- **Storage:** Firebase Storage (tutor ID verification documents)

See the project report, Section "Tech Stack Selection & Justification," for the full rationale.

## Team & Workload

| Reg.No | Name | Module Owned |
|---|---|---|
| IT23817944 | Rashmika P G R D | Onboarding, Auth & Profile |
| IT23820982 | Kalhara W A D S | Discovery & Search |
| IT23819924 | Malavipathirana I.D.M | Booking & Scheduling |
| IT23724884 | Sandavinna P N R | Messaging, Reviews & Integrity |

## Setup Instructions

Start with [Firebase access, registration and each member's CRUD demonstration](docs/firebase-and-crud-guide.md). For local data run `powershell -NoProfile -ExecutionPolicy Bypass -File backend/start-local.ps1`; for your hosted Firebase project follow that guide and run `backend/run-cloud.ps1`.

The app now uses Firebase data. Follow [backend setup](docs/backend-setup.md) for the local emulators, synthetic accounts, cloud configuration and build commands. See [Milestone 03 requirements](docs/milestone-03-requirements.md) for assessment traceability and evidence still needed. The older quick-start below assumes cloud configuration; debug builds default to local emulators.

### Prerequisites
- Flutter SDK (stable channel)
- Android Studio or VS Code with Flutter extension
- A Firebase project with Firestore, Authentication, and Storage enabled

### Steps to run locally
```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/sliit-peer-tutoring-app.git
cd sliit-peer-tutoring-app

# 2. Install dependencies
flutter pub get

# 3. Add your own Firebase config files (not included in this repo for security):
#    - android/app/google-services.json
#    - ios/Runner/GoogleService-Info.plist
#    Request these from the project owner, or set up your own Firebase project
#    using the schema described in /docs/firebase-schema.md

# 4. Run the app
flutter run
```

### Building a release APK
```bash
flutter build apk --release
```
Output APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Branch Structure
- `main` — stable, merged code
- `rashmika-onboarding`
- `kalhara-discovery`
- `malavipathirana-booking`
- `sandavinna-messaging`

## Testing
Automated checks are in `test/` and `backend/rules.test.cjs`. Backend tests require running Firebase emulators. Actual participant usability testing and the consolidated report remain group submission work.

## License
Academic project — SLIIT IT3060 Human Computer Interaction, 2026.
