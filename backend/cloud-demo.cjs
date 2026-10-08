// Explicitly synthetic fixtures for the user's sliit-peer-tutoring project.
// Creates missing records only; never resets existing profiles or workflows.
const fs = require('node:fs');
const path = require('node:path');
const { fields } = require('./emulator.cjs');
const project = 'sliit-peer-tutoring';
const password = 'PeerDemo123!';
const fixtures = [
  ['student', 'Demo Student', 'tutee', true, []],
  ['hci', 'Demo HCI Tutor', 'tutor', true, ['IT3060','IT2080']],
  ['programming', 'Demo Programming Tutor', 'tutor', true, ['IT1010','IT2030']],
  ['networks', 'Demo Networks Tutor', 'tutor', true, ['IT3040','IT2050']],
  ['pending', 'Demo Pending Tutor', 'tutor', false, ['IT3060']],
];
function prepare(ids) {
  const records = [];
  const add = (document, data) => records.push({document, data});
  const now = new Date();
  for (const [key,name,role,approved,subjects] of fixtures) {
    const uid = ids[key];
    add(`users/${uid}`, {name,email:`codex-demo-${key}@my.sliit.lk`,role,year:role==='tutor'?'Year 3':'Year 2',
      program:'Information Technology',verificationStatus:approved?'approved':'pending',verificationEvidence:null,
      guidelinesAccepted:true,createdAt:now});
    if (role==='tutor') add(`tutorProfiles/${uid}`, {userId:uid,name,year:'Year 3',program:'Information Technology',subjects,
      bio:'Synthetic demonstration profile for the assignment. This is not a real student or enrollment approval.',verified:approved});
  }
  const colombo = new Date(now.getTime()+330*60000);
  const slots = [];
  for (const key of ['hci','programming','networks']) {
    for (let day=1;day<=7;day++) {
      const start = new Date(Date.UTC(colombo.getUTCFullYear(),colombo.getUTCMonth(),colombo.getUTCDate()+day,9,30));
      const id = `${ids[key]}_${start.getTime()}`;
      const slot = {tutorId:ids[key],start,end:new Date(start.getTime()+90*60000),available:true,bookingId:null,
        mode:day%2?'Campus':'Online',venue:day%2?'Demo campus discussion room':'Microsoft Teams'};
      if (key==='hci' && day<=2) slot.bookingId=`codex-demo-${day===1?'pending':'confirmed'}`;
      slots.push({id,...slot});
      add(`availability/${id}`,slot);
    }
  }
  function booking(id,slot,status) {
    const data = {tutorId:ids.hci,tuteeId:ids.student,participants:[ids.hci,ids.student],
      tutorName:'Demo HCI Tutor',tuteeName:'Demo Student',module:'IT3060',slotId:slot.id,start:slot.start,end:slot.end,
      mode:slot.mode,venue:slot.venue,notes:'Synthetic HCI concept revision session.',teamsUrl:null,status,createdAt:now};
    add(`bookings/${id}`,data);
  }
  booking('codex-demo-pending',slots[0],'pending');
  booking('codex-demo-confirmed',slots[1],'confirmed');
  const pastStart = new Date(now.getTime()-2*86400000);
  const past = {id:`${ids.hci}_${pastStart.getTime()}`,tutorId:ids.hci,start:pastStart,end:new Date(pastStart.getTime()+90*60000),
    mode:'Campus',venue:'Demo campus discussion room',available:true,bookingId:null};
  const {id:pastId,...pastData}=past;
  add(`availability/${pastId}`,pastData);
  booking('codex-demo-completed',past,'completed');
  add('reviews/codex-demo-completed',{bookingId:'codex-demo-completed',tutorId:ids.hci,tuteeId:ids.student,
    author:'Demo Student',rating:5,comment:'Demo review: clear explanations of usability heuristics.',tags:[],createdAt:now});
  add(`users/${ids.student}/favorites/${ids.hci}`,{tutorId:ids.hci,note:'Demo note: revise HCI concepts.',createdAt:now});
  const members=[ids.student,ids.hci].sort(), chatId=members.join('_');
  add(`chats/${chatId}`,{members,names:{[ids.student]:'Demo Student',[ids.hci]:'Demo HCI Tutor'},bookingId:'codex-demo-completed',createdAt:now});
  add(`chats/${chatId}/messages/codex-demo-message`,{senderId:ids.student,text:'Demo message: can we revise usability heuristics?',attachment:null,createdAt:now});
  add('notifications/codex-demo-confirmed',{userId:ids.student,actorId:ids.hci,type:'booking',bookingId:'codex-demo-confirmed',
    chatId:null,message:'Demo session confirmation.',read:false,createdAt:now});
  add('reports/codex-demo-report',{bookingId:'codex-demo-completed',reporterId:ids.student,reason:'Other',
    details:'Synthetic confidential report for demonstrating report access. No real incident is alleged.',evidence:null,status:'submitted',createdAt:now});
  return records;
}
async function main() {
  const root = path.resolve(__dirname,'..');
  const placeholders = Object.fromEntries(fixtures.map(([key])=>[key,`demo-${key}-uid`]));
  fs.writeFileSync(path.join(__dirname,'demo-data.json'),JSON.stringify({project,synthetic:true,records:prepare(placeholders)},null,2));
  if (!process.argv.includes('--import')) { console.log('Prepared backend/demo-data.json; no cloud writes.'); return; }
  const config = JSON.parse(fs.readFileSync(path.join(root,'android/app/google-services.json'),'utf8'));
  if(config.project_info.project_id!==project) throw new Error('Unexpected Firebase project.');
  const client=config.client.find(c=>c.client_info.android_client_info.package_name==='com.example.sliit_peer_tutoring');
  const key=client.api_key[0].current_key;
  async function request(url,method,body,token) {
    const response=await fetch(url,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},
      body:body===undefined?undefined:JSON.stringify(body),signal:AbortSignal.timeout(60000)});
    const data=await response.json();
    if(!response.ok) {const error=new Error(data.error?.message || `HTTP ${response.status}`);error.status=response.status;throw error;}
    return data;
  }
  const auth=require(path.resolve(process.argv[process.argv.indexOf('--cli-root')+1],'lib/auth.js'));
  const account=auth.getGlobalDefaultAccount();
  if(!account) throw new Error('Sign in with firebase.cmd login first.');
  const token=(await auth.getAccessToken(account.tokens.refresh_token,['https://www.googleapis.com/auth/cloud-platform'])).access_token;
  const base=`https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents`;
  // Validate admin access before creating any fixture authentication accounts.
  await request(base+'/users?pageSize=1','GET',undefined,token);
  const ids={};
  for(const [name] of fixtures) {
    const email=`codex-demo-${name}@my.sliit.lk`;
    let user;
    try {user=await request(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${key}`,'POST',{email,password,returnSecureToken:true});}
    catch(error) {
      if(error.message!=='EMAIL_EXISTS') throw error;
      user=await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${key}`,'POST',{email,password,returnSecureToken:true});
    }
    ids[name]=user.localId;
  }
  const records=prepare(ids);
  fs.writeFileSync(path.join(__dirname,'demo-data.json'),JSON.stringify({project,synthetic:true,records},null,2));
  const writes=[];
  for(const record of records) {
    try {await request(`${base}/${record.document}`,'GET',undefined,token);}
    catch(error) {
      if(error.status!==404) throw error;
      writes.push({update:{name:`projects/${project}/databases/(default)/documents/${record.document}`,fields:fields(record.data)},currentDocument:{exists:false}});
    }
  }
  if(writes.length) await request(base+':commit','POST',{writes},token);
  for(const record of records) await request(`${base}/${record.document}`,'GET',undefined,token);
  console.log(`Verified ${records.length} demo documents; created ${writes.length}. Existing records were preserved.`);
  console.log('Accounts: '+fixtures.map(([name])=>`codex-demo-${name}@my.sliit.lk`).join(', '));
  console.log('Demo password: '+password);
}
if(require.main===module) main().catch(error=>{console.error(error.message);process.exitCode=1;});
module.exports={prepare,fixtures};
