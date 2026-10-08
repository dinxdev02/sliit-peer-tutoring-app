const assert = require('node:assert/strict');
const project = 'demo-sliit-peer';
const authBase = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1';
const firestoreBase = `http://127.0.0.1:8080/v1/projects/${project}/databases/(default)/documents`;

function value(v) {
  if (v === null) return { nullValue: null };
  if (v instanceof Date) return { timestampValue: v.toISOString() };
  if (typeof v === 'string') return { stringValue: v };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (typeof v === 'number') return Number.isInteger(v) ? { integerValue: String(v) } : { doubleValue: v };
  if (Array.isArray(v)) return { arrayValue: { values: v.map(value) } };
  return { mapValue: { fields: fields(v) } };
}
function fields(data) { return Object.fromEntries(Object.entries(data).map(([key, v]) => [key, value(v)])); }
function decode(v) {
  if ('nullValue' in v) return null;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('doubleValue' in v) return v.doubleValue;
  if ('timestampValue' in v) return new Date(v.timestampValue);
  if ('arrayValue' in v) return (v.arrayValue.values || []).map(decode);
  if ('mapValue' in v) return Object.fromEntries(Object.entries(v.mapValue.fields || {}).map(([k, x]) => [k, decode(x)]));
  return v.stringValue ?? v.booleanValue;
}
async function request(url, method, body, token) {
  assert(url.startsWith('http://127.0.0.1:'), 'Tools are restricted to local emulators.');
  const response = await fetch(url, { method, headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body === undefined ? undefined : JSON.stringify(body), signal: AbortSignal.timeout(30000) });
  const text = await response.text();
  const data = text ? JSON.parse(text) : {};
  if (!response.ok) { const error = new Error(data.error?.message || text); error.status = response.status; throw error; }
  return data;
}
async function signIn(email, password = 'PeerDemo123!') {
  return request(`${authBase}/accounts:signInWithPassword?key=demo-key`, 'POST', { email, password, returnSecureToken: true });
}
async function account(email, password = 'PeerDemo123!') {
  try { return await request(`${authBase}/accounts:signUp?key=demo-key`, 'POST', { email, password, returnSecureToken: true }); }
  catch (error) { if (!error.message.includes('EMAIL_EXISTS')) throw error; return signIn(email, password); }
}
async function set(path, data, token = 'owner') { return request(`${firestoreBase}/${path}`, 'PATCH', { fields: fields(data) }, token); }
async function get(path, token = 'owner') { const doc = await request(`${firestoreBase}/${path}`, 'GET', undefined, token); return { id: doc.name.split('/').pop(), ...Object.fromEntries(Object.entries(doc.fields || {}).map(([k, v]) => [k, decode(v)])) }; }
async function remove(path, token) { return request(`${firestoreBase}/${path}`, 'DELETE', undefined, token); }
async function commit(writes, token) { return request(`${firestoreBase}:commit`, 'POST', { writes }, token); }
function write(path, data, mask) { return { update: { name: `projects/${project}/databases/(default)/documents/${path}`, fields: fields(data) }, ...(mask ? { updateMask: { fieldPaths: mask } } : {}) }; }
module.exports = { project, fields, decode, request, account, signIn, set, get, remove, commit, write, firestoreBase };
