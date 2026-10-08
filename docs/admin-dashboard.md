# Assignment administrator

The login screen accepts username `admin` and password `admin` for the assignment demonstration. This alias authenticates the provisioned `assignment-admin@my.sliit.lk` Firebase account with a six-or-more-character underlying password, because Firebase email/password accounts require at least six characters. The demo credentials and underlying password are public in this source and must be replaced before production use.

Administrator access requires both the Firebase-issued `admin` custom claim and the designated account email. A profile role or client-side screen route does not grant Firestore privileges. The account was provisioned through the existing authenticated Firebase CLI session with `node backend/provision-admin.cjs <firebase-tools package directory>`. This script is only for trusted project administrators; it cannot be run by an app user to obtain permissions.

The separate Admin Dashboard is inside the same app. Sign out of the student account and sign in as `admin` to open it. It lists tutor applications, including modules and introductions. Incomplete tutor profiles cannot be approved. Approve, reject and revoke actions update `users.verificationStatus` and `tutorProfiles.verified` together in a Firestore transaction. Students cannot approve themselves. Pending and rejected profiles are excluded from public tutor discovery and new bookings. Student ID uploads remain optional and Firebase Storage is not needed.

Validation: Flutter analysis; 28 Flutter tests; authenticated cloud integration checks of admin login, rejection, approval and denied student access. Live integration checks create temporary audit accounts and remove their records afterward; existing applications are preserved.
