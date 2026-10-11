// Adapted NNN.docx cases in original TC01 to TC11 order. Backend assertions only.
// Authenticated integration check. All writes use new audit accounts/documents.
// Administrator access is used only for fixture approval and final cleanup.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {fields,decode,write} = require('./emulator.cjs');
const project='sliit-peer-tutoring';
async function main() {
  const config=JSON.parse(fs.readFileSync(path.resolve(__dirname,'../android/app/google-services.json'),'utf8'));
  assert.equal(config.project_info.project_id,project);
  const client=config.client.find(c=>c.client_info.android_client_info.package_name==='com.example.sliit_peer_tutoring');
  const key=client.api_key[0].current_key;
  const auth=require(path.resolve(process.argv[2],'lib/auth.js'));
  const account=auth.getGlobalDefaultAccount();
  if(!account) throw new Error('Firebase CLI login is required.');
  const admin=(await auth.getAccessToken(account.tokens.refresh_token,['https://www.googleapis.com/auth/cloud-platform'])).access_token;
  const base=`https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents`;
  async function request(url,method,body,token) {
    const response=await fetch(url,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},
      body:body===undefined?undefined:JSON.stringify(body),signal:AbortSignal.timeout(60000)});
    const text=await response.text(), data=text?JSON.parse(text):{};
    if(!response.ok){const error=new Error(data.error?.message||`HTTP ${response.status}`);error.status=response.status;throw error;}
    return data;
  }
  const tracked=new Set(), accounts=[];
  const set=async(p,d,t)=>{tracked.add(p);return request(base+'/'+p,'PATCH',{fields:fields(d)},t);};
  const get=async(p,t)=>{const doc=await request(base+'/'+p,'GET',undefined,t);return Object.fromEntries(Object.entries(doc.fields||{}).map(([k,v])=>[k,decode(v)]));};
  const remove=(p,t)=>request(base+'/'+p,'DELETE',undefined,t);
  const commit=(records,t)=>{
    const writes=records.map(([p,d,mask])=>{
      tracked.add(p);
      const w=write(p,d,mask);w.update.name=`projects/${project}/databases/(default)/documents/${p}`;return w;
    });
    return request(base+':commit','POST',{writes},t);
  };
  const stamp=Date.now(), prefix=`audit-${stamp}`;
  async function signup(role) {
    const email=`codex-${prefix}-${role}@my.sliit.lk`;
    const user=await request(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${key}`,'POST',
      {email,password:'PeerAudit123!',returnSecureToken:true});
    accounts.push(user);
    const profile={name:`Audit ${role}`,email,role:role==='tutor'?'tutor':'tutee',year:'Year 2',program:'Information Technology',
      verificationStatus:'pending',verificationEvidence:null,guidelinesAccepted:false,pledgeAccepted:true,pledgeAcceptedAt:new Date(),createdAt:new Date()};
    await set(`users/${user.localId}`,profile,user.idToken);
    assert.equal((await get(`users/${user.localId}`,user.idToken)).verificationEvidence,null);
    return user;
  }
  let complete=false;
  try {

    const student=await signup('student'),tutor=await signup('tutor'),pending=await signup('pending');
    const s=student.localId,t=tutor.localId,p=pending.localId;
    const fixture={userId:t,name:'Sequence tutor',year:'Year 2',program:'Information Technology',subjects:['IT3060'],bio:'Synthetic testing only',verified:true};
    await set(`users/${t}`,{...(await get(`users/${t}`,admin)),role:'tutor',verificationStatus:'approved'},admin);
    await set(`users/${p}`,{...(await get(`users/${p}`,admin)),role:'tutor'},admin);
    await set(`tutorProfiles/${t}`,fixture,admin);
    await set(`tutorProfiles/${p}`,{...fixture,userId:p,verified:false},admin);
    const query=await request(base+':runQuery','POST',{structuredQuery:{from:[{collectionId:'tutorProfiles'}],where:{fieldFilter:{field:{fieldPath:'verified'},op:'EQUAL',value:{booleanValue:true}}}}},student.idToken);
    const ids=query.filter(x=>x.document).map(x=>x.document.name.split('/').pop());
    assert(ids.includes(t));assert(!ids.includes(p));
    const matches=query.filter(x=>x.document).map(x=>Object.fromEntries(Object.entries(x.document.fields).map(([k,v])=>[k,decode(v)]))).filter(x=>x.subjects.includes('IT3060'));
    assert(matches.some(x=>x.userId===t));
    console.log('TC01 PASS backend approved tutor discovery and module matching; typing UI not exercised');
    await commit([[`users/${s}`,{guidelinesAccepted:true},['guidelinesAccepted']]],student.idToken);
    const slotId=prefix+'-slot',bookingId=prefix+'-booking';
    const start=new Date(Date.now()+3*86400000),end=new Date(start.getTime()+3600000);
    const slot={tutorId:t,start,end,mode:'Campus',venue:'Sequence test room',available:true,bookingId:null};
    await set(`availability/${slotId}`,slot,tutor.idToken);
    const booking={tutorId:t,tuteeId:s,participants:[t,s],tutorName:'Sequence tutor',tuteeName:'Audit student',module:'IT3060',slotId,start,end,mode:'Campus',venue:slot.venue,notes:'Synthetic sequence test',teamsUrl:null,status:'pending',createdAt:new Date()};
    await commit([[`bookings/${bookingId}`,booking],[`availability/${slotId}`,{bookingId},['bookingId']]],student.idToken);
    assert.equal((await get(`bookings/${bookingId}`,student.idToken)).slotId,slotId);
    assert.equal((await get(`availability/${slotId}`,student.idToken)).bookingId,bookingId);
    console.log('TC02 PASS backend session request creation and slot lock; pending until tutor acceptance');
    console.log('TC03 NOT APPLICABLE restaurant live queue and waiting-time feature');
    await commit([[`bookings/${bookingId}`,{status:'cancelled'},['status']],[`availability/${slotId}`,{bookingId:null},['bookingId']]],student.idToken);
    assert.equal((await get(`bookings/${bookingId}`,tutor.idToken)).status,'cancelled');
    assert.equal((await get(`availability/${slotId}`,student.idToken)).bookingId,null);
    console.log('TC04 PARTIAL pending cancellation and slot release pass; cancellation notification not exercised');
    await commit([[`users/${s}`,{name:'Sequence Updated Student'},['name']]],student.idToken);
    const fresh=await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${key}`,'POST',{email:student.email,password:'PeerAudit123!',returnSecureToken:true});
    assert.equal((await get(`users/${s}`,fresh.idToken)).name,'Sequence Updated Student');
    console.log('TC05 PASS backend profile update persists after fresh authentication');
    await remove(`tutorProfiles/${p}`,admin);
    const pendingProfile={...fixture,userId:p,name:'Pending sequence tutor',verified:false};
    await set(`tutorProfiles/${p}`,pendingProfile,pending.idToken);
    assert.equal((await get(`tutorProfiles/${p}`,pending.idToken)).verified,false);
    await set(`tutorProfiles/${p}`,{...pendingProfile,bio:'Updated introduction'},pending.idToken);
    assert.equal((await get(`tutorProfiles/${p}`,pending.idToken)).bio,'Updated introduction');
    await assert.rejects(()=>set(`tutorProfiles/${p}`,{...pendingProfile,verified:true},pending.idToken),e=>e.status===403);
    console.log('TC06 PASS backend pending tutor profile create update and denied self-approval');
    await set(`availability/${slotId}`,{...slot,venue:'Updated sequence room'},tutor.idToken);
    assert.equal((await get(`availability/${slotId}`,student.idToken)).venue,'Updated sequence room');
    await set(`availability/${slotId}`,{...slot,venue:'Updated sequence room',available:false},tutor.idToken);
    assert.equal((await get(`availability/${slotId}`,student.idToken)).available,false);
    console.log('TC07 PASS backend availability update visible through student readback; stream latency not measured');
    console.log('TC08 NOT APPLICABLE restaurant occupancy PDF generation');
    const dashboardAdmin=await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${key}`,'POST',{email:'assignment-admin@my.sliit.lk',password:'AssignmentAdmin123!',returnSecureToken:true});
    assert.equal(JSON.parse(Buffer.from(dashboardAdmin.idToken.split('.')[1],'base64url').toString()).admin,true);
    await commit([[`users/${p}`,{verificationStatus:'approved'},['verificationStatus']],[`tutorProfiles/${p}`,{verified:true},['verified']]],dashboardAdmin.idToken);
    assert.equal((await get(`users/${p}`,pending.idToken)).verificationStatus,'approved');
    assert.equal((await get(`tutorProfiles/${p}`,student.idToken)).verified,true);
    console.log('TC09 PASS authenticated administrator approval updates private and public verification');
    await commit([[`users/${p}`,{verificationStatus:'rejected'},['verificationStatus']],[`tutorProfiles/${p}`,{verified:false},['verified']]],dashboardAdmin.idToken);
    assert.equal((await get(`users/${p}`,pending.idToken)).verificationStatus,'rejected');
    await assert.rejects(get(`tutorProfiles/${p}`,student.idToken),e=>e.status===403);
    console.log('TC10 PARTIAL rejection and discovery access restriction pass; rejection notification not exercised');
    console.log('TC11 NOT APPLICABLE administrator account-deletion feature is not implemented');
    complete=true;
  } finally {
    let failures=0;
    for(const p of [...tracked].reverse()) {
      try {await remove(p,admin);} catch(error) {if(error.status!==404){failures++;console.error('Cleanup failed for '+p);}}
    }
    for(const user of accounts) {
      try {await request(`https://identitytoolkit.googleapis.com/v1/accounts:delete?key=${key}`,'POST',{idToken:user.idToken});}
      catch {failures++;console.error('Audit authentication cleanup failed.');}
    }
    if(failures) throw new Error(`${failures} audit cleanup operations failed.`);
    console.log('Audit documents and accounts removed; existing app data preserved.');
  }
  assert(complete);
}
main().catch(error=>{console.error(error.message);process.exitCode=1;});
