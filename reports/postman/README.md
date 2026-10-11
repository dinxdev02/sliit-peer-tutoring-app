# SLIIT Peer API tests for the viva

Import `SLIIT-Peer.postman_collection.json` and `SLIIT-Peer.postman_environment.json` into Postman. Select the imported environment.

Fill `apiKey` locally from android/app/google-services.json (client.api_key.current_key). Fill `adminPassword` using the configured assignment administrator password. Keep these values private. Do not export a populated environment or screenshot tokens/passwords.

Run the whole collection once, in numbered order, with one iteration. Requests 01–09 test registration, profile creation/read/update, persistence after fresh login, and denied access. Requests 10–12 clean up the temporary profile and authentication account. The email is generated automatically, so existing students are not edited.

A 403 response is a PASS for requests 07–09: it demonstrates that the security rules reject unauthorized access. Successful requests expect 200. Tests also check the email and persisted name.

If the run stops, complete cleanup requests 10–12 before another run. Do not rerun registration first: it replaces the temporary UID. If authentication cleanup fails because the token expired, run request 05 again, then 12. Verify both cleanup requests succeed.

For screenshots: show the collection results and test assertions, then a successful response with tokens hidden. Add the genuine run date and outcomes to the report. These are API tests, separate from app UI tests and human usability sessions. This collection does not cover bookings, messaging or reviews.

Explain at the viva: “Our Flutter app uses Firebase. We tested the Firebase Auth and Firestore REST APIs with Postman assertions, including both successful operations and permission denials. We also tested the app interface separately.”

`actual-run-results.json`, when present, records execution of this collection through Newman, the Postman collection runner. It is not a screenshot or claim of execution in the Postman desktop interface.
