const { doc, getDoc, setDoc, updateDoc, deleteDoc } = require('firebase/firestore');
const {
  setupTestEnv,
  teardownTestEnv,
  clearData,
  seed,
  asUser,
  asAnonymous,
  assertSucceeds,
  assertFails,
} = require('./helpers');

describe('users/{uid}', () => {
  before(setupTestEnv);
  after(teardownTestEnv);
  afterEach(clearData);

  beforeEach(() =>
    seed(async (context) => {
      await setDoc(doc(context.firestore(), 'users/alice'), {
        nickname: '앨리스',
      });
    }),
  );

  it('로그인한 사람은 남의 프로필도 읽을 수 있다', async () => {
    const db = asUser('bob').firestore();
    await assertSucceeds(getDoc(doc(db, 'users/alice')));
  });

  it('로그인하지 않으면 프로필을 읽을 수 없다', async () => {
    const db = asAnonymous().firestore();
    await assertFails(getDoc(doc(db, 'users/alice')));
  });

  it('본인 uid 문서는 만들 수 있다', async () => {
    const db = asUser('bob').firestore();
    await assertSucceeds(
      setDoc(doc(db, 'users/bob'), { nickname: '밥' }),
    );
  });

  it('남의 uid로는 프로필을 만들 수 없다', async () => {
    const db = asUser('bob').firestore();
    await assertFails(
      setDoc(doc(db, 'users/carol'), { nickname: '가짜' }),
    );
  });

  it('본인 프로필은 수정할 수 있다', async () => {
    const db = asUser('alice').firestore();
    await assertSucceeds(
      updateDoc(doc(db, 'users/alice'), { nickname: '앨리스2' }),
    );
  });

  it('남의 프로필은 수정할 수 없다', async () => {
    const db = asUser('bob').firestore();
    await assertFails(
      updateDoc(doc(db, 'users/alice'), { nickname: '해킹됨' }),
    );
  });

  it('프로필은 본인도 지울 수 없다', async () => {
    const db = asUser('alice').firestore();
    await assertFails(deleteDoc(doc(db, 'users/alice')));
  });
});
