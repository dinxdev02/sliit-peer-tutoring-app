const { test, before } = require('node:test');
const assert = require('node:assert/strict');
const { seed } = require('./seed.cjs');
const { set, get, remove, commit, write, request, firestoreBase } = require('./emulator.cjs');
let users;
before(async () => {
  users = await seed();
  // Clean only this suite's named fixtures; preserve unrelated local records.
  for (const collection of ['availability', 'bookings', 'notifications', 'reviews', 'chats', 'reports']) {
    const rows = await request(`${firestoreBase}:runQuery`, 'POST', { structuredQuery: { from: [{ collectionId: collection }] } }, 'owner');
    for (const row of rows) {
      const id = row.document?.name.split('/').pop();
      if (id && (id.startsWith('test-') || ['race-a','race-b'].includes(id))) await remove(`${collection}/${id}`, 'owner');
    }
  }
});
test('FR1: registration can create a pending profile without an ID upload',async()=>{
  const {account} = require('./emulator.cjs');
  const registered = await account('registration-test@my.sliit.lk');
  const path = `users/${registered.localId}`;
  try {
    await remove(path,'owner');
    await set(path, {name:'Registration Test',email:registered.email,role:'tutee',year:'Year 1',program:'Information Technology',
      verificationStatus:'pending',verificationEvidence:null,guidelinesAccepted:false,pledgeAccepted:true,pledgeAcceptedAt:new Date(),createdAt:new Date()},registered.idToken);
    assert.equal((await get(path,registered.idToken)).verificationEvidence,null);
    assert.equal((await get(path,registered.idToken)).verificationStatus,'pending');
    assert.equal((await get(path,registered.idToken)).pledgeAccepted,true);
  } finally {
    await remove(path,'owner');
  }
});
const future = () => new Date(Date.now() + 3 * 86400000);
function slot(tutor, start = future()) { return { tutorId: tutor.localId, start, end: new Date(start.getTime() + 3600000), mode: 'Campus', venue: 'Library L204', available: true, bookingId: null }; }
function booking(id, s, student = users.student) { return { tutorId: users.tutor.localId, tuteeId: student.localId, participants: [users.tutor.localId, student.localId],
  tutorName: 'Demo Peer Tutor', tuteeName: student.localId === users.student.localId ? 'Demo Student' : 'Pending Tutor',
  module: 'IT3060', slotId: id, start: s.start, end: s.end, mode: s.mode, venue: s.venue, notes: '', teamsUrl: null, status: 'pending', createdAt: new Date() }; }
async function requestBooking(id, s, bookingId = id, student = users.student, version) {
  const userDoc = await get(`users/${student.localId}`); delete userDoc.id;
  await set(`users/${student.localId}`, { ...userDoc, guidelinesAccepted: true }, student.idToken);
  const lock = write(`availability/${id}`, { bookingId }, ['bookingId']);
  if (version) lock.currentDocument = { updateTime: version };
  return commit([write(`bookings/${bookingId}`, booking(id,s,student)), lock], student.idToken);
}

test('FR5: pending tutors cannot appear in public discovery or self-verify', async () => {
  await assert.rejects(get(`tutorProfiles/${users.pending.localId}`, users.student.idToken));
  const pending = await get(`tutorProfiles/${users.pending.localId}`); delete pending.id;
  await assert.rejects(set(`tutorProfiles/${users.pending.localId}`, { ...pending, verified: true }, users.pending.idToken));
  const user = await get(`users/${users.pending.localId}`); delete user.id;
  await assert.rejects(set(`users/${users.pending.localId}`, { ...user, verificationStatus: 'approved' }, users.pending.idToken));
});
test('FR1 / privacy: only owners read or edit private student profiles', async () => {
  assert.equal((await get(`users/${users.student.localId}`, users.student.idToken)).name, 'Demo Student');
  await assert.rejects(get(`users/${users.student.localId}`, users.tutor.idToken));
});
test('FR2 / FR9: verified tutor discovery query succeeds', async () => {
  const result = await request(`${firestoreBase}:runQuery`, 'POST', { structuredQuery: { from: [{ collectionId: 'tutorProfiles' }],
    where: { fieldFilter: { field: { fieldPath: 'verified' }, op: 'EQUAL', value: { booleanValue: true } } } } }, users.student.idToken);
  assert(result.some(row => row.document?.name.endsWith(users.tutor.localId)));
  assert(!result.some(row => row.document?.name.endsWith(users.pending.localId)));
});
test('FR3: availability create/read/update/delete is restricted to its tutor', async () => {
  const s = slot(users.tutor);
  await set('availability/test-crud', s, users.tutor.idToken);
  assert.equal((await get('availability/test-crud', users.student.idToken)).venue, 'Library L204');
  await set('availability/test-crud', { ...s, venue: 'Library L205' }, users.tutor.idToken);
  await assert.rejects(remove('availability/test-crud', users.student.idToken));
  await remove('availability/test-crud', users.tutor.idToken);
});
test('FR3 / FR10: concurrent requests reserve a slot exactly once', async () => {
  const id = 'test-concurrent', s = slot(users.tutor); await set(`availability/${id}`,s);
  const raw = await request(`${firestoreBase}/availability/${id}`, 'GET', undefined, 'owner');
  const results = await Promise.allSettled([requestBooking(id,s,'race-a',users.student,raw.updateTime), requestBooking(id,s,'race-b',users.pending,raw.updateTime)]);
  assert.equal(results.filter(r => r.status === 'fulfilled').length,1);
  const reservation = await get(`availability/${id}`); assert(['race-a','race-b'].includes(reservation.bookingId));
});
test('FR8 / FR10: participant acceptance and cancellation are authorized; strangers are denied', async () => {
  const id='test-transition',s=slot(users.tutor); await set(`availability/${id}`,s); await requestBooking(id,s);
  await assert.rejects(commit([write(`bookings/${id}`,{status:'confirmed'},['status'])],users.student.idToken));
  await commit([write(`bookings/${id}`,{status:'confirmed'},['status'])],users.tutor.idToken);
  const notification={userId:users.student.localId,actorId:users.tutor.localId,type:'booking',bookingId:id,chatId:null,message:'Confirmed',read:false,createdAt:new Date()};
  await set('notifications/test-confirmed',notification,users.tutor.idToken);
  assert.equal((await get('notifications/test-confirmed',users.student.idToken)).read,false);
  await commit([write('notifications/test-confirmed',{read:true},['read'])],users.student.idToken);
  assert.equal((await get('notifications/test-confirmed',users.student.idToken)).read,true);
  await assert.rejects(commit([write('notifications/test-confirmed',{message:'Forged'},['message'])],users.student.idToken));
  await remove('notifications/test-confirmed',users.student.idToken);
  await assert.rejects(get(`bookings/${id}`,users.pending.idToken));
  await commit([write(`bookings/${id}`,{status:'cancelled'},['status']),write(`availability/${id}`,{bookingId:null},['bookingId'])],users.student.idToken);
  assert.equal((await get(`availability/${id}`)).bookingId,null);
});
test('FR10: rescheduling atomically releases the old slot and reserves the new one', async () => {
  const oldId='test-reschedule-old', newId='test-reschedule-new', id='test-reschedule';
  const old=slot(users.tutor), next=slot(users.tutor,new Date(Date.now()+4*86400000));
  await set(`availability/${oldId}`,old); await set(`availability/${newId}`,next);
  await requestBooking(oldId,old,id);
  await commit([write(`bookings/${id}`,{slotId:newId,start:next.start,end:next.end,mode:next.mode,venue:next.venue,status:'pending',teamsUrl:null},['slotId','start','end','mode','venue','status','teamsUrl']),
    write(`availability/${oldId}`,{bookingId:null},['bookingId']),write(`availability/${newId}`,{bookingId:id},['bookingId'])],users.student.idToken);
  assert.equal((await get(`availability/${oldId}`)).bookingId,null);
  assert.equal((await get(`availability/${newId}`)).bookingId,id);
  assert.equal((await get(`bookings/${id}`,users.tutor.idToken)).slotId,newId);
  await assert.rejects(remove(`availability/${newId}`,users.tutor.idToken));
});
test('FR4: reviews require completed sessions and support own update/delete',async()=>{
  const review={bookingId:'demo-completed',tutorId:users.tutor.localId,tuteeId:users.student.localId,author:'Demo Student',rating:5,comment:'Clear explanations',tags:[],createdAt:new Date()};
  await set('reviews/demo-completed',review,users.student.idToken);
  await set('reviews/demo-completed',{...review,rating:4},users.student.idToken);
  assert.equal((await get('reviews/demo-completed',users.tutor.idToken)).rating,4);
  await assert.rejects(set('reviews/fake-session',{...review,bookingId:'fake-session'},users.student.idToken));
  await assert.rejects(remove('reviews/demo-completed',users.tutor.idToken));
  await remove('reviews/demo-completed',users.student.idToken);
});
test('FR4 / privacy: only chat members can read or send messages',async()=>{
  const chat={members:[users.student.localId,users.tutor.localId],names:{[users.student.localId]:'Demo Student',[users.tutor.localId]:'Demo Peer Tutor'},bookingId:null,createdAt:new Date()};
  await set('chats/test-chat',chat,users.student.idToken);
  await commit([write('chats/test-chat',{bookingId:'demo-completed'},['bookingId'])],users.student.idToken);
  assert.equal((await get('chats/test-chat',users.tutor.idToken)).bookingId,'demo-completed');
  await assert.rejects(commit([write('chats/test-chat',{bookingId:'missing-booking'},['bookingId'])],users.student.idToken));
  const message={senderId:users.student.localId,text:'Can we discuss the rubric?',attachment:null,createdAt:new Date()};
  await set('chats/test-chat/messages/test-message',message,users.student.idToken);
  assert.equal((await get('chats/test-chat/messages/test-message',users.tutor.idToken)).text,message.text);
  await assert.rejects(get('chats/test-chat/messages/test-message',users.pending.idToken));
  await assert.rejects(set('chats/test-chat/messages/forged',message,users.tutor.idToken));
  await remove('chats/test-chat/messages/test-message',users.student.idToken);
});
test('FR6: submitted reports are confidential and cannot be rewritten by participants',async()=>{
  const report={bookingId:'demo-completed',reporterId:users.student.localId,reason:'Other',details:'A detailed test report for review.',evidence:null,status:'submitted',createdAt:new Date()};
  await set('reports/test-report',report,users.student.idToken);
  assert.equal((await get('reports/test-report',users.student.idToken)).status,'submitted');
  await assert.rejects(get('reports/test-report',users.tutor.idToken));
  await assert.rejects(set('reports/test-report',{...report,details:'Changed report'},users.student.idToken));
});
test('FR9: favorites persist and can be removed by their owner',async()=>{
  const path=`users/${users.student.localId}/favorites/${users.tutor.localId}`;
  await set(path,{tutorId:users.tutor.localId,createdAt:new Date()},users.student.idToken);
  assert.equal((await get(path,users.student.idToken)).tutorId,users.tutor.localId);
  await set(path,{tutorId:users.tutor.localId,createdAt:new Date(),note:'Revise HCI heuristics'},users.student.idToken);
  assert.equal((await get(path,users.student.idToken)).note,'Revise HCI heuristics');
  await assert.rejects(set(path,{tutorId:users.tutor.localId,createdAt:new Date(),note:'x'.repeat(301)},users.student.idToken));
  await assert.rejects(set(path,{tutorId:users.tutor.localId,createdAt:new Date(),note:'Changed by another user'},users.tutor.idToken));
  await assert.rejects(get(path,users.tutor.idToken));
  await remove(path,users.student.idToken);
});

test('FR1: owners create, read, update and remove their tutor profile',async()=>{
  const original = await get(`tutorProfiles/${users.pending.localId}`); delete original.id;
  await remove(`tutorProfiles/${users.pending.localId}`,users.pending.idToken);
  await set(`tutorProfiles/${users.pending.localId}`,original,users.pending.idToken);
  await set(`tutorProfiles/${users.pending.localId}`,{...original,bio:'Updated academic introduction'},users.pending.idToken);
  assert.equal((await get(`tutorProfiles/${users.pending.localId}`,users.pending.idToken)).bio,'Updated academic introduction');
  await assert.rejects(remove(`tutorProfiles/${users.pending.localId}`,users.student.idToken));
  await remove(`tutorProfiles/${users.pending.localId}`,users.pending.idToken);
  await assert.rejects(get(`tutorProfiles/${users.pending.localId}`,users.pending.idToken));
  await set(`tutorProfiles/${users.pending.localId}`,original,users.pending.idToken);
});
