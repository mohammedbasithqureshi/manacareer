import { initializeApp, getApps, cert } from 'firebase-admin/app';
import * as fs from 'fs';
import * as path from 'path';

const serviceAccount = JSON.parse(
  fs.readFileSync(path.join(process.cwd(), 'firebase-service-account.json'), 'utf8'),
);

if (getApps().length === 0) {
  initializeApp({
    credential: cert(serviceAccount),
  });
}