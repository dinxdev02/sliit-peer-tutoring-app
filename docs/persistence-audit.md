# Persistence audit — 8 October 2026

Registration saves the submitted profile to `users/{uid}`, including name, email, role, year, program, verification status, academic integrity pledge and its timestamp. The profile is created in a transaction so retries cannot overwrite an existing profile. Login reads the existing profile. Passwords remain in Firebase Authentication.

Other submitted records are persisted in `tutorProfiles`, `availability`, `bookings`, `users/{uid}/favorites`, `chats`, `chats/{id}/messages`, `notifications`, `reviews` and `reports`. Unsaved form input, navigation tabs and current search/filter selections remain transient interface state. Student ID uploads are optional; the cloud build disables uploads and stores null evidence.

Fixed during this audit:

- Registration pledge was checked in the UI but not saved; it is now persisted, including after resumed registration.
- Reusing a chat for a booking did not update its booking association. Only members can change that field, and both members must be participants of the referenced booking.
- Reopened availability showed default mode/venue. It now restores saved values from Firestore-backed slots.
- Review edits replaced the original creation timestamp. Saves now preserve it in a transaction.

Validation:

- Flutter analysis: no issues.
- Flutter tests with uploads disabled: 27 passed.
- Firestore rules compiled and deployed to `sliit-peer-tutoring`.
- `backend/cloud-persistence-check.cjs`: authenticated REST integration checks passed for registration without uploads, pledge/profile persistence, fresh-login readback, tutor profiles, availability, favorites, shared bookings, chat booking linkage, messages, notifications, reviews, private reports, cancellation and owner deletion.
- Temporary synthetic accounts/documents were removed after testing. Existing app data was preserved.

These live checks verify server persistence and authorization. Widget tests cover rendering and saved-value restoration. They do not replace a manual device walkthrough of every interaction or the assignment's participant usability testing. The full local emulator rule suite remains a separate check.
