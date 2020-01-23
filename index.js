const fs = require('fs');
const childProcess = require('child_process');

const server = process.env.INPUT_SERVER;
const account = process.env.INPUT_ACCOUNT || 'Administrator';
const password = process.env.INPUT_PASSWORD;
const artifact = process.env.INPUT_ARTIFACT;
const path = process.env.INPUT_PATH;

if (!server) {
  throw new Error('Input required and not supplied: server');
}
if (!password) {
  throw new Error('Input required and not supplied: password');
}
if (!artifact || !fs.existsSync(artifact)) {
  throw new Error('Artifact not exist');
}
if (!path) {
  throw new Error('Input required and not supplied: path');
}

const child = childProcess.spawn('PowerShell.exe', [
  '-NoProfile',
  '-File',
  `${__dirname}\\deploy.ps1`,
  server,
  account,
  password,
  artifact,
  path
]);
child.stdout.on('data', (data) => {
  console.log(`${data}`.trim());
});
child.stdin.end();
