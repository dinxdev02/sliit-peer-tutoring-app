# Prepared Firestore demo data

`backend/demo-data.json` contains 40 related synthetic records prepared before import. `backend/cloud-demo.cjs` binds fixture records to real Firebase Authentication UIDs during import. All names, enrollment approvals, sessions, messages, reviews and reports in this dataset are demonstration fixtures, not real university data.

| Records | Count | Purpose |
| --- | --- | --- |
| Private user profiles | 5 | One student, three visible tutors, one pending tutor |
| Tutor profiles | 4 | Module search, academic profile CRUD and pending visibility |
| Availability | 22 | Future Campus/Online slots and a completed session's past slot |
| Bookings | 3 | Pending, confirmed and completed workflows |
| Reviews | 1 | Read/edit/delete; the completed session allows recreation |
| Saved tutor | 1 | Read/edit private note/remove; recreate by saving |
| Conversation and message | 2 | Send/read/delete message demonstration |
| Notification | 1 | Read/mark read/delete |
| Confidential report | 1 | Reporter-only read; create a separate report in the app |

Accounts use password `PeerDemo123!`:

- `codex-demo-student@my.sliit.lk`
- `codex-demo-hci@my.sliit.lk`
- `codex-demo-programming@my.sliit.lk`
- `codex-demo-networks@my.sliit.lk`
- `codex-demo-pending@my.sliit.lk`

The approved tutors are explicitly synthetic approvals for demonstration. New users still register normally and are not automatically approved. No student ID, report evidence or message attachment is uploaded.

To prepare the JSON only: `node backend/cloud-demo.cjs`. To import, pass `--import --cli-root` with the Firebase CLI package directory. The importer is fixed to project `sliit-peer-tutoring`, checks the Android configuration and administrator access, creates missing accounts, atomically creates missing Firestore documents with `exists: false`, and reads each document back. Existing records are preserved. Re-running does not reset reviews, bookings or profiles already present.

After an intentional CRUD deletion, re-import can recreate a missing fixture. For future test dates, create new availability through the tutor calendar rather than treating the seed as production scheduling.
