const { doc, getDoc, setDoc, deleteDoc, addDoc, collection } = require('firebase/firestore');
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

describe('feedback/{feedbackId}', () => {
  before(setupTestEnv);
  after(teardownTestEnv);
  afterEach(clearData);

  it('로그인하지 않아도 피드백을 제출할 수 있다', async () => {
    const db = asAnonymous().firestore();
    await assertSucceeds(
      addDoc(collection(db, 'feedback'), { message: '좋아요' }),
    );
  });

  it('제출된 피드백은 아무도 읽을 수 없다', async () => {
    await seed((context) =>
      setDoc(doc(context.firestore(), 'feedback/f1'), { message: '좋아요' }),
    );
    const db = asUser('alice').firestore();
    await assertFails(getDoc(doc(db, 'feedback/f1')));
  });

  it('제출된 피드백은 아무도 지울 수 없다', async () => {
    await seed((context) =>
      setDoc(doc(context.firestore(), 'feedback/f1'), { message: '좋아요' }),
    );
    const db = asUser('alice').firestore();
    await assertFails(deleteDoc(doc(db, 'feedback/f1')));
  });
});

describe('정의되지 않은 컬렉션(catch-all)', () => {
  before(setupTestEnv);
  after(teardownTestEnv);
  afterEach(clearData);

  it('로그인한 사람이라도 읽을 수 없다', async () => {
    await seed((context) =>
      setDoc(doc(context.firestore(), 'somethingElse/x'), { a: 1 }),
    );
    const db = asUser('alice').firestore();
    await assertFails(getDoc(doc(db, 'somethingElse/x')));
  });

  it('로그인한 사람이라도 쓸 수 없다', async () => {
    const db = asUser('alice').firestore();
    await assertFails(setDoc(doc(db, 'somethingElse/x'), { a: 1 }));
  });
});
