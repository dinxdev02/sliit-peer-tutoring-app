# Access Firebase and demonstrate the four members' CRUD workflows

## Where the data lives

The Android emulator is a virtual phone. The Firebase emulators are separate local backend services. Opening the phone alone does not start the database.

- **Local development:** open http://127.0.0.1:4000 after `backend/start-local.ps1` reports Firebase ready. Authentication lists accounts, Firestore lists records, and Storage lists uploaded files. The project is `demo-sliit-peer`. Local records do not appear in the cloud console.
- **Cloud:** open https://console.firebase.google.com/project/sliit-peer-tutoring/overview for the supplied **SLIIT Peer Tutoring** project (`sliit-peer-tutoring`, project number `746372732214`). Authentication > Users lists registered accounts; Firestore Database > Data shows documents; Storage shows files. Cloud records persist independently of your computer. The matching Android configuration is present locally and excluded from Git; other developers must download their own copy. Service enablement and rules deployment must be verified separately.

## Connect your own cloud project

1. Create or select a project in Firebase Console.
2. Under Authentication > Sign-in method, enable Email/Password.
3. Create a Cloud Firestore database. The current cloud version does not require Firebase Storage: student ID uploads are optional and all file upload controls are disabled by `backend/run-cloud.ps1`.
4. Register an Android app with package `com.example.sliit_peer_tutoring`. Download its `google-services.json` into `android/app/google-services.json`.
5. From the repository root, authenticate Firebase CLI and deploy the repository's rules to the exact project ID you selected:

```powershell
firebase.cmd login
firebase.cmd deploy --only firestore:rules,firestore:indexes --project sliit-peer-tutoring
```

Review `firestore.rules` before deployment. Do not enable unrestricted database access to work around a permission error. Storage rules only need deployment if file uploads are enabled later.

6. With the Android emulator running, launch the cloud app:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File backend/run-cloud.ps1
```

This reads the downloaded Android configuration and explicitly disables Firebase emulator mode. It does not deploy rules or create a project. Normal `flutter run` in debug mode still uses the local backend.

## Register and proceed

Choose Get Started, select student or tutor, and enter your own name, an `@my.sliit.lk` email and a password of at least six characters. Select year/program and continue without uploading an ID. The app creates an Authentication account and a private `users/{uid}` profile with `verificationEvidence: null`. Local builds can optionally upload a synthetic document, but it is never required to complete registration. The cloud version supports text chat and text-only reports without Storage.

Students can then discover tutors and request sessions. Tutors complete academic setup, publish availability and manage requests. Tutor discovery requires enrollment approval. If registration is interrupted after creating the Authentication account, sign in again; the app resumes the missing profile step instead of opening an incomplete dashboard.

For local tests, the student and tutor demo accounts use `student@my.sliit.lk` and `tutor@my.sliit.lk`, password `PeerDemo123!`. A newly registered local tutor can be approved after reviewing its test document:

```powershell
node backend/approve.cjs USER_UID
```

For cloud approval, a trusted project administrator verifies enrollment separately, sets `users/{uid}.verificationStatus` to `approved`, and sets `tutorProfiles/{uid}.verified` to `true` if a tutor profile exists. Skipping the optional document does not automatically verify enrollment. Users cannot approve themselves. No production administrator app is included.

## CRUD demonstration matrix

These are the four member feature areas, not four kinds of users. The app has student and tutor roles.

| Member / area | Create | Read | Update | Delete | Firestore records |
| --- | --- | --- | --- | --- | --- |
| Rashmika: onboarding and profiles | Register; save tutor profile | My Profile; academic setup | Edit name/year/program; tutor modules/bio | Remove Tutor Profile, returning to student mode | `users`, `tutorProfiles` |
| Kalhara: discovery and saved tutors | Save Tutor | Search; tutor details; Saved Tutors | Edit Private Note in Saved Tutors | Remove Saved Tutor | `users/{uid}/favorites` |
| Malavipathirana: availability and booking | Select future slots and Save; request session | Calendar, schedule, booking details | Change mode/venue; accept/decline/reschedule/cancel | Deselect an unreserved future slot and Save | `availability`, `bookings` |
| Sandavinna: reviews and messaging | Submit a review after a completed session; send message | Tutor reviews, Reviews Given, conversation | Edit own review | Delete own review/message | `reviews`, `chats/{id}/messages` |

Cancelling a booking updates its status; it does not delete its document. Deleting availability provides the scheduling area's delete operation. Reports remain immutable to participants and are not counted as full CRUD. Tutor-profile removal preserves existing bookings/messages. Search and filter changes are read operations, not database updates.

For each demonstration, inspect the corresponding document in Firebase, perform the action in the app, then restart/sign in again to confirm persistence. Use two accounts for request/acceptance and messaging. A tutor marks an ended confirmed session completed before its student can review it. Reserved slots cannot be deleted.

## Validation and marks

The stored assignment summary requires at least two working CRUD operations per assigned interface. A feature-area CRUD table does not prove every individual screen meets that requirement. Welcome, role selection and other navigation screens do not write records. Check the assessor's expected interface boundaries using the original assignment brief.

`backend/rules.test.cjs` covers authorization and database workflows; `docs/test-traceability.md` maps these cases to requirements. Run it with the backend ready:

```powershell
node --test backend/rules.test.cjs
flutter analyze
flutter test
```

Record actual results and screenshots. Source code alone is not proof that the workflow works on a device. The group must also conduct the required five-participant usability testing and prepare submission evidence.
