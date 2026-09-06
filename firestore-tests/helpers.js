// 모든 테스트 파일이 공유하는 에뮬레이터 초기화 로직.
// firestore.rules 원본 파일을 그대로 읽어서 에뮬레이터에 올리기 때문에,
// 앱이 실제로 배포하는 규칙과 테스트 대상이 항상 같다.
const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const PROJECT_ID = 'demo-mini-game-app';

let testEnv;

async function setupTestEnv() {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(
        path.join(__dirname, '..', 'firestore.rules'),
        'utf8',
      ),
      host: '127.0.0.1',
      port: 8080,
    },
  });
}

async function teardownTestEnv() {
  await testEnv.cleanup();
}

async function clearData() {
  await testEnv.clearFirestore();
}

// 보안 규칙을 우회해서 테스트용 데이터를 미리 심어둘 때 쓴다.
function seed(fn) {
  return testEnv.withSecurityRulesDisabled(fn);
}

function asUser(uid) {
  return testEnv.authenticatedContext(uid);
}

function asAnonymous() {
  return testEnv.unauthenticatedContext();
}

module.exports = {
  setupTestEnv,
  teardownTestEnv,
  clearData,
  seed,
  asUser,
  asAnonymous,
  assertSucceeds,
  assertFails,
};
