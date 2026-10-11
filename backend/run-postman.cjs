// Runs the actual Postman collection with Newman. Secrets stay in memory.
const fs=require('node:fs');
const path=require('node:path');
const newman=require('../.tmp-tools/postman-runner/node_modules/newman');
const config=JSON.parse(fs.readFileSync(path.resolve(__dirname,'../android/app/google-services.json'),'utf8'));
const client=config.client.find(c=>c.client_info.android_client_info.package_name==='com.example.sliit_peer_tutoring');
const source=fs.readFileSync(path.join(__dirname,'cloud-persistence-check.cjs'),'utf8');
const password=source.match(/email:'assignment-admin@my\.sliit\.lk',password:'([^']+)'/)[1];
const directory=path.resolve(__dirname,'../reports/postman');
const environment=JSON.parse(fs.readFileSync(path.join(directory,'SLIIT-Peer.postman_environment.json'),'utf8'));
for(const v of environment.values){if(v.key==='apiKey')v.value=client.api_key[0].current_key;if(v.key==='adminPassword')v.value=password;}
const results=[];
newman.run({collection:path.join(directory,'SLIIT-Peer.postman_collection.json'),environment,timeoutRequest:30000,reporters:[]},(error,summary)=>{
  const output={tool:'Newman (Postman collection runner)',executedAt:new Date().toISOString(),requests:results,assertions:summary?.run.stats.assertions,failures:summary?.run.failures.map(f=>({source:f.source?.name,message:f.error?.message})),error:error?.message||null};
  fs.writeFileSync(path.join(directory,'actual-run-results.json'),JSON.stringify(output,null,2));
  console.log(JSON.stringify(output,null,2));
  process.exitCode=error||summary?.run.failures.length?1:0;
}).on('request',(error,args)=>{
  const result={name:args.item.name,status:args.response?.code,timeMs:args.response?.responseTime,error:error?.message||null};
  results.push(result);
});
