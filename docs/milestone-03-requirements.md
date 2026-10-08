# Milestone 03 implementation requirements

Sources reviewed: Assignment 3.pdf, the WE_134 Milestone 01 and 02 reports, and the Assignment 1 and 2 briefs supplied by the user. These documents describe assessment requirements; the user's instruction is to connect the existing application to real data without changing its established flow.

Assignment 3 is due **9 October 2026**. It requires a working installable mobile application, at least two working CRUD operations per assigned interface, functional test cases traced to requirements, usability testing with at least five real/proxy participants, a version-controlled repository with setup instructions, an installable build, and a consolidated report of at most 35 pages excluding references and appendix. Existing prototype usability results are context, not evidence of testing the working application.

| Requirement | Responsible workload | Required data workflow |
| --- | --- | --- |
| FR1 | Rashmika: authentication and profiles | Register/sign in; create/read/update student and tutor profiles; add/remove tutor subjects and year |
| FR2 | Kalhara: discovery | Read verified tutors; search immediately as text changes; apply/reset module, availability, mode and rating filters |
| FR3 | Malavipathirana: scheduling | Create/read/update/delete future available slots; prevent conflicting reservations |
| FR4 | Sandavinna: reviews and messaging | Create/read/update/delete own review after completed sessions; show real tutor reviews; send/read session messages |
| FR5 | Rashmika: verification | Upload enrollment evidence privately; pending tutors are not public; only a trusted administrator approves verification |
| FR6 | Sandavinna: reports | Create/read own confidential session reports and upload optional evidence |
| FR7 | Sandavinna: integrity | Read and acknowledge academic guidelines before the first booking; store acknowledgement |
| FR8 | Malavipathirana/shared | Persist booking/message notifications for intended recipients; read/mark read/delete notifications |
| FR9 | Kalhara: fair discovery | Discover the available verified tutor population; save/remove favorites without ranking solely by popularity |
| FR10 | Malavipathirana: booking | Persist selected date/time/venue; tutor accepts/declines; student cancels/reschedules; both sides read the same booking |

Preserve onboarding → registration/verification → home/search → tutor profile → request confirmation → schedule/details → chat → post-session review/report. Preserve tutor setup → availability → request management. Loading, empty, failure and pending-verification states replace sample content.

Earlier testing highlighted immediate search/filter reset, a scrollable availability grid, visible booking back navigation and usable notification targets. Keep these behaviors in the implementation.

## Submission evidence still requiring the group

The user requested a no-upload cloud workflow on 7 October 2026. Student ID uploads are now optional; cloud builds disable file uploads and use Authentication plus Firestore. FR5 document evidence and FR6 uploaded report evidence are therefore deviations from the original implementation scope and must be explained in the report. Enrollment approval remains an administrator decision.

- Capture actual results for each functional test (including negative and concurrent booking cases), linking requirement → prototype → screen → test.
- Run usability sessions with at least five participants on the working application; record tasks, timings, outcomes, issues, severity and fixes. Do not reuse prototype outcomes as implementation results.
- Record workload ownership, architecture/technology justification and prototype deviations in the consolidated report.
- Produce a tested APK, repository link and demo instructions; each member must be able to explain their work.

No user-testing results or administrative approvals are invented by this document.
