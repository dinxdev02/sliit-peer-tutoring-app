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
    await request(base+'/users?pageSize=1','GET',undefined,admin);
    const student=await signup('student'),tutor=await signup('tutor');
    const s=student.localId,t=tutor.localId;
    let profile=await get(`users/${s}`,student.idToken);
    await set(`users/${s}`,{...profile,name:'Audit Updated Student',guidelinesAccepted:true},student.idToken);
    const relogged=await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${key}`,'POST',
      {email:student.email,password:'PeerAudit123!',returnSecureToken:true});
    assert.equal((await get(`users/${s}`,relogged.idToken)).name,'Audit Updated Student');
    console.log('PASS registration without upload, pledge, profile edit and fresh-login readback');
    const tutorProfile={userId:t,name:'Audit tutor',year:'Year 2',program:'Information Technology',subjects:['IT3060'],bio:'Synthetic audit profile.',verified:false};
    await set(`tutorProfiles/${t}`,tutorProfile,tutor.idToken);
    await set(`tutorProfiles/${t}`,{...tutorProfile,bio:'Updated synthetic introduction.'},tutor.idToken);
    assert.equal((await get(`tutorProfiles/${t}`,tutor.idToken)).bio,'Updated synthetic introduction.');
    const dashboardAdmin=await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${key}`,'POST',
      {email:'assignment-admin@my.sliit.lk',password:'AssignmentAdmin123!',returnSecureToken:true});
    const claims=JSON.parse(Buffer.from(dashboardAdmin.idToken.split('.')[1],'base64url').toString());
    assert.equal(claims.admin,true);
    await assert.rejects(() => set(`tutorProfiles/${t}`,{...tutorProfile,verified:true},tutor.idToken),e=>e.status===403);
    await assert.rejects(() => request(base+'/users','GET',undefined,student.idToken),e=>e.status===403);
    await commit([[`users/${t}`,{verificationStatus:'rejected'},['verificationStatus']],
      [`tutorProfiles/${t}`,{verified:false},['verified']]],dashboardAdmin.idToken);
    assert.equal((await get(`users/${t}`,tutor.idToken)).verificationStatus,'rejected');
    await commit([[`users/${t}`,{verificationStatus:'approved'},['verificationStatus']],
      [`tutorProfiles/${t}`,{verified:true},['verified']]],dashboardAdmin.idToken);
    assert.equal((await get(`tutorProfiles/${t}`,student.idToken)).verified,true);
    console.log('PASS administrator login, rejection, approval and denied student administrator access');
    const tutorUser=await get(`users/${t}`,admin);
    await set(`users/${t}`,{...tutorUser,verificationStatus:'approved'},admin);
    await set(`tutorProfiles/${t}`,{...tutorProfile,verified:true},admin);
    const slotId=prefix+'-slot', bookingId=prefix+'-booking';
    const start=new Date(Date.now()+3*86400000),end=new Date(start.getTime()+3600000);
    const slot={tutorId:t,start,end,mode:'Campus',venue:'Audit room',available:true,bookingId:null};
    await set(`availability/${slotId}`,slot,tutor.idToken);
    await set(`availability/${slotId}`,{...slot,venue:'Updated audit room'},tutor.idToken);
    assert.equal((await get(`availability/${slotId}`,student.idToken)).venue,'Updated audit room');
    const favorite=`users/${s}/favorites/${t}`;
    await set(favorite,{tutorId:t,createdAt:new Date()},student.idToken);
    await set(favorite,{tutorId:t,createdAt:new Date(),note:'Saved audit note'},student.idToken);
    assert.equal((await get(favorite,relogged.idToken)).note,'Saved audit note');
    const booking={tutorId:t,tuteeId:s,participants:[t,s],tutorName:'Audit tutor',tuteeName:'Audit Updated Student',module:'IT3060',
      slotId,start,end,mode:'Campus',venue:'Updated audit room',notes:'Persistent audit notes',teamsUrl:null,status:'pending',createdAt:new Date()};
    await commit([[`bookings/${bookingId}`,booking],[`availability/${slotId}`,{bookingId},['bookingId']]],student.idToken);
    assert.equal((await get(`bookings/${bookingId}`,tutor.idToken)).notes,'Persistent audit notes');
    await commit([[`bookings/${bookingId}`,{status:'confirmed'},['status']]],tutor.idToken);
    assert.equal((await get(`bookings/${bookingId}`,relogged.idToken)).status,'confirmed');
    console.log('PASS tutor profile, availability, favorites and shared booking persistence');
    const chatId=prefix+'-chat', messageId=prefix+'-message', notificationId=prefix+'-notification';
    await set(`chats/${chatId}`,{members:[s,t],names:{[s]:'Audit Updated Student',[t]:'Audit tutor'},bookingId:null,createdAt:new Date()},student.idToken);
    await commit([[`chats/${chatId}`,{bookingId},['bookingId']]],student.idToken);
    assert.equal((await get(`chats/${chatId}`,tutor.idToken)).bookingId,bookingId);
    await commit([
      [`chats/${chatId}/messages/${messageId}`,{senderId:s,text:'Persistent audit message',attachment:null,createdAt:new Date()}],
      [`notifications/${notificationId}`,{userId:t,actorId:s,type:'message',chatId,bookingId:null,message:'Audit notification',read:false,createdAt:new Date()}]
    ],student.idToken);
    assert.equal((await get(`chats/${chatId}/messages/${messageId}`,tutor.idToken)).text,'Persistent audit message');
    await commit([[`notifications/${notificationId}`,{read:true},['read']]],tutor.idToken);
    assert.equal((await get(`notifications/${notificationId}`,tutor.idToken)).read,true);
    const pastId=prefix+'-completed';
    await set(`bookings/${pastId}`,{...booking,status:'completed',start:new Date(Date.now()-7200000),end:new Date(Date.now()-3600000)},admin);
    const review={bookingId:pastId,tutorId:t,tuteeId:s,author:'Audit Updated Student',rating:5,comment:'Audit review',tags:[],createdAt:new Date()};
    await set(`reviews/${pastId}`,review,student.idToken);
    await set(`reviews/${pastId}`,{...review,rating:4,comment:'Updated audit review'},student.idToken);
    assert.equal((await get(`reviews/${pastId}`,tutor.idToken)).rating,4);
    const reportId=prefix+'-report';
    await set(`reports/${reportId}`,{bookingId:pastId,reporterId:s,reason:'Other',details:'Synthetic persistence audit; no actual incident.',evidence:null,status:'submitted',createdAt:new Date()},student.idToken);
    assert.equal((await get(`reports/${reportId}`,relogged.idToken)).evidence,null);
    await assert.rejects(get(`reports/${reportId}`,tutor.idToken),e=>e.status===403);
    console.log('PASS chat booking link, message, notification, review and private report readback');
    await commit([[`bookings/${bookingId}`,{status:'cancelled'},['status']],[`availability/${slotId}`,{bookingId:null},['bookingId']]],student.idToken);
    for(const [p,token] of [[favorite,student.idToken],[`reviews/${pastId}`,student.idToken],[`chats/${chatId}/messages/${messageId}`,student.idToken],
      [`notifications/${notificationId}`,tutor.idToken],[`availability/${slotId}`,tutor.idToken],[`tutorProfiles/${t}`,tutor.idToken]]) {
      await remove(p,token);await assert.rejects(get(p,token),e=>e.status===404 || e.status===403);
    }
    console.log('PASS cancellation and owner deletion persistence');
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
