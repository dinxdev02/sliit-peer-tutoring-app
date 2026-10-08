# Functional test traceability

## Recorded checks

On 8 October 2026, 27 Flutter tests passed with uploads disabled and analysis reported no issues. The authenticated cloud persistence audit passed and cleaned up its temporary accounts/documents. See `docs/persistence-audit.md` for the tested operations, fixes and limits.

- `flutter test --no-pub`: 26 widget tests passed on 7 October 2026. Twenty check empty-state screens at 320px and 390px width; the others cover onboarding rendering, filter reset, stored request identity/status, blocking reviews of pending sessions, interrupted registration recovery and missing tutor-profile recovery. These are automated UI checks, not usability sessions.
- `flutter analyze --no-pub`: no issues found during the implementation. Rerun after changing source.
- Backend rule tests and authenticated device workflows require running Firebase emulators. Their source exists, but a passing result must be recorded only after execution.
- Cloud configuration for `sliit-peer-tutoring` is connected through `backend/run-cloud.ps1`. Firestore rules compiled and rules/indexes deployed successfully on 7 October 2026. All 26 Flutter tests also passed with `--dart-define=ENABLE_FILE_UPLOADS=false`, and analysis reported no issues. Registration now allows `verificationEvidence: null`; Storage is not required for the cloud workflow. Authenticated device CRUD remains unverified until exercised on the installed build.

## Automated backend cases

Run `node --test backend/rules.test.cjs` after all local emulators are ready. This suite resets its named synthetic fixtures and seed profiles; use a separate demo project, never production. It sends requests through the real Firestore rules using different account tokens.

| Requirements | Prototype interface | Test case in rules.test.cjs | Expected result |
| --- | --- | --- | --- |
| FR1 | Student profile | Private profile ownership | Owner reads; another student is denied |
| FR5 | Verification / tutor setup | Pending tutor visibility and self-verification | Pending profile excluded; self-approval denied |
| FR2, FR9 | Search / tutor profile | Verified discovery query | Approved tutors returned; pending tutors excluded |
| FR3 | Availability calendar | Availability CRUD ownership | Tutor creates, reads, updates and deletes free slots; other users cannot delete |
| FR3, FR10 | Request session | Concurrent reservation | Exactly one conflicting request succeeds |
| FR8, FR10 | Tutor dashboard / bookings / notifications | Accept, cancel and notification ownership | Tutor accepts; student cannot self-accept; cancel releases slot; notification recipient reads/marks/deletes |
| FR10 | Booking details | Reschedule transaction | Old slot released, new slot locked, booking returns to pending; reserved slot cannot be deleted |
| FR4 | Review modal | Completed-session review CRUD | Student writes/edits/deletes review; nonexistent session and other owners denied |
| FR4 | Chat | Conversation membership | Only members read/send; forged sender denied; own message deletion works |
| FR6 | Report session issue | Confidential immutable report | Reporter creates/reads; tutor cannot read or rewrite |
| FR9 | Search / saved tutors | Favorites CRUD and private notes | Save/read/update note/remove persists for the owner; another account and oversized notes denied |
| FR1 | Tutor academic setup | Tutor profile CRUD | Owner creates/reads/updates/removes own profile; another account denied |

## Working-app manual checks

Use distinct student and tutor accounts. Record actual date, device, build identifier, result and screenshot for each case.

1. Register with a SLIIT email and a valid document; confirm pending verification and that self-approval is unavailable. Reject invalid email, invalid password, oversized/unsupported files and cancelled selection. Retry an interrupted registration.
2. Edit profile and tutor subjects; restart/sign in again and verify persistence. Search by name/module, clear search and reset every filter; save/remove a tutor and verify the Saved Tutors view.
3. Save tutor availability, switch weeks and restart; verify stored slots. Reserve one slot from two students, verify only one succeeds, and confirm reserved slots cannot be removed. Test venue and Teams modes.
4. Request, accept, decline, reschedule and cancel from the correct accounts. Verify both accounts receive consistent dates/status and notifications. Complete an ended session as tutor; student may then create/update/delete its review.
5. Send text and a supported attachment; verify reception, own-message deletion and external opening. Test a third account's denied access. Enter a valid Teams URL for online confirmation.
6. Submit a detailed, confirmed report with optional evidence; verify only the reporter and trusted administrator can read it. Check notification marking/deletion, logout, network failure and retry states.

Storage authorization, email/password recovery and external meeting/file opening need live emulator/device verification in addition to the Firestore test suite. Background push notifications, automatic Teams creation and production administrator approval tooling are outside the implemented integration.

## Usability study evidence

Recruit at least five real/proxy participants and test the installed working app. The previous prototype's participants/results do not establish usability of this build. Use discover-and-book, tutor availability/acceptance, chat, review and report tasks. Leave this table blank until sessions occur.

| Participant | Task | Success / assistance | Time | Observed issue | Severity | Fix and retest |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | | | | | | |
| P2 | | | | | | |
| P3 | | | | | | |
| P4 | | | | | | |
| P5 | | | | | | |

Read-only navigation/helper screens (welcome, role selection and confirmation) should be distinguished from data-management interfaces when documenting the assignment's two-CRUD-operation requirement. The group must reconcile that interpretation with its assessor; do not claim writes on a screen that only displays a record.
