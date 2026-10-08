const { get, set } = require('./emulator.cjs');
(async () => {
  const uid = process.argv[2];
  if (!uid) throw new Error('Usage: node backend/approve.cjs USER_UID. Review enrollment evidence before approving.');
  const user = await get(`users/${uid}`); delete user.id;
  await set(`users/${uid}`, { ...user, verificationStatus: 'approved' });
  try { const tutor = await get(`tutorProfiles/${uid}`); delete tutor.id; await set(`tutorProfiles/${uid}`, { ...tutor, verified: true }); }
  catch (error) { if (error.status !== 404) throw error; }
  console.log('Enrollment approved in the local emulator.');
})().catch(error => { console.error(error.message); process.exitCode = 1; });
