// Resume interrupted official Firebase runtime downloads and verify their SHA-256.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const info = require(path.resolve(process.argv[2]));
const root = path.resolve(__dirname, '../.tmp-tools/emulators');
fs.mkdirSync(root, { recursive: true });
async function download(spec) {
  const target = path.join(root, spec.downloadPathRelativeToCacheDir);
  const hash = buffer => crypto.createHash('sha256').update(buffer).digest('hex');
  if (fs.existsSync(target) && fs.statSync(target).size === spec.expectedSize &&
      hash(fs.readFileSync(target)) === spec.expectedChecksumSHA256) return;
  const count = 12, size = Math.ceil(spec.expectedSize / count);
  const parts = await Promise.all(Array.from({ length: count }, async (_, i) => {
    const start = i * size, end = Math.min(spec.expectedSize - 1, start + size - 1);
    const part = `${target}.part${i}`;
    for (let attempt = 0; attempt < 12; attempt++) {
      const offset = fs.existsSync(part) ? fs.statSync(part).size : 0;
      if (offset === end - start + 1) return fs.readFileSync(part);
      if (offset > end - start + 1) throw new Error(`Invalid cached part: ${part}`);
      try {
        const response = await fetch(spec.remoteUrl, {
          headers: { Range: `bytes=${start + offset}-${end}` }, signal: AbortSignal.timeout(180000)
        });
        if (response.status !== 206) throw new Error(`Range response ${response.status}`);
        for await (const chunk of response.body) fs.appendFileSync(part, Buffer.from(chunk));
      } catch (error) {
        console.log(`${spec.downloadPathRelativeToCacheDir}, part ${i + 1}: ${error.message}; resuming`);
        if (attempt === 11) throw error;
      }
    }
    if (fs.statSync(part).size !== end - start + 1) throw new Error('Incomplete runtime download');
    return fs.readFileSync(part);
  }));
  const result = Buffer.concat(parts);
  if (hash(result) !== spec.expectedChecksumSHA256) throw new Error('Official runtime checksum mismatch');
  fs.writeFileSync(target, result);
  console.log(`Verified ${spec.downloadPathRelativeToCacheDir}`);
}
Promise.all([download(info.firestore), download(info.storage), download(info.ui.main)]).catch(error => {
  console.error(error.message); process.exitCode = 1;
});
