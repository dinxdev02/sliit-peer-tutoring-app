const { account, set, project } = require('./emulator.cjs');
async function seed() {
  const student = await account('student@my.sliit.lk');
  const tutor = await account('tutor@my.sliit.lk');
  const pending = await account('pending@my.sliit.lk');
  const users = [[student, 'Demo Student', 'tutee', true], [tutor, 'Demo Peer Tutor', 'tutor', true], [pending, 'Pending Tutor', 'tutor', false]];
  for (const [user, name, role, approved] of users) {
    await set(`users/${user.localId}`, { name, email: user.email, role, year: role === 'tutor' ? 'Year 3' : 'Year 2', program: 'Information Technology',
      verificationStatus: approved ? 'approved' : 'pending', verificationEvidence: null, guidelinesAccepted: false, createdAt: new Date() });
    if (role === 'tutor') await set(`tutorProfiles/${user.localId}`, { userId: user.localId, name, year: 'Year 3', program: 'Information Technology',
      subjects: ['IT3060','IT2080','IT1010'], bio: 'Local demonstration account for explaining concepts and practising the peer tutoring workflow.', verified: approved });
  }
  for (let day = 1; day <= 7; day++) {
    const start = new Date(); start.setDate(start.getDate() + day); start.setHours(15, 0, 0, 0);
    await set(`availability/${tutor.localId}_${start.getTime()}`, { tutorId: tutor.localId, start, end: new Date(start.getTime() + 90 * 60000),
      available: true, bookingId: null, mode: day % 2 ? 'Campus' : 'Online', venue: day % 2 ? 'SLIIT Malabe Library, Discussion Room L204' : 'Microsoft Teams' });
  }
  const end = new Date(Date.now() - 86400000), start = new Date(end.getTime() - 3600000);
  await set('bookings/demo-completed', { tutorId: tutor.localId, tuteeId: student.localId, participants: [tutor.localId, student.localId],
    tutorName: 'Demo Peer Tutor', tuteeName: 'Demo Student', module: 'IT3060', slotId: 'demo-past-slot', start, end,
    mode: 'Campus', venue: 'SLIIT Malabe Library', notes: 'Practice Nielsen’s heuristics and severity ratings.', teamsUrl: null, status: 'completed', createdAt: start });
  console.log(`Seeded ${project}. Local synthetic accounts only; not real enrollment approvals.`);
  console.log('student@my.sliit.lk / tutor@my.sliit.lk / pending@my.sliit.lk');
  console.log('Password: PeerDemo123!');
  return { student, tutor, pending };
}
if (require.main === module) seed().catch(error => { console.error(error.message); process.exitCode = 1; });
module.exports = { seed };
