// Provision the assignment demo administrator using the existing Firebase CLI login.
const fs=require('node:fs'),path=require('node:path');
async function main(){
 const config=JSON.parse(fs.readFileSync(path.resolve(__dirname,'../android/app/google-services.json'),'utf8'));
 const project=config.project_info.project_id;
 if(project!=='sliit-peer-tutoring') throw Error('Unexpected project');
 const auth=require(path.resolve(process.argv[2],'lib/auth.js'));
 const account=auth.getGlobalDefaultAccount();
 if(!account) throw Error('Firebase CLI login required');
 const token=(await auth.getAccessToken(account.tokens.refresh_token,['https://www.googleapis.com/auth/cloud-platform'])).access_token;
 async function api(action,body){
  const r=await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${project}/accounts`+(action ? ':'+action : ''),{method:'POST',headers:{'Content-Type':'application/json',Authorization:`Bearer ${token}`},body:JSON.stringify(body),signal:AbortSignal.timeout(60000)});
  const d=await r.json();if(!r.ok) throw Error(d.error?.message);return d;
 }
 const email='assignment-admin@my.sliit.lk';
 const existing=await api('lookup',{email:[email]});

 const existingUser = existing.users?.[0] || existing;
 let uid=existingUser.localId;
 if(!uid){const created=await api('',{email,password:'AssignmentAdmin123!',displayName:'Assignment Administrator',emailVerified:true});uid=created.localId;}
 // Preserve other claims; only this specifically provisioned account is granted admin.
 const claims=JSON.parse(existingUser.customAttributes || '{}');
 await api('update',{localId:uid,password:'AssignmentAdmin123!',customAttributes:JSON.stringify({...claims,admin:true})});
 console.log('Administrator provisioned. Demo login: admin / admin.');
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
