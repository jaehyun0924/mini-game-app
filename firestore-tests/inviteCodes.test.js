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

describe('inviteCodes/{code}', () => {
  before(setupTestEnv);
  after(teardownTestEnv);
  afterEach(clearData);

  beforeEach(() =>
    seed(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'groups/g1'), {
        name: '연구실',
        inviteCode: 'ABC123',
        ownerId: 'alice',
        memberIds: ['alice', 'bob'],
      });
      await setDoc(doc(db, 'inviteCodes/ABC123'), { groupId: 'g1' });
    }),
  );

  it('로그인한 사람은 코드를 읽을 수 있다', async () => {
    const db = asUser('mallory').firestore();
    await assertSucceeds(getDoc(doc(db, 'inviteCodes/ABC123')));
  });

  it('로그인하지 않으면 코드를 읽을 수 없다', async () => {
    const db = asAnonymous().firestore();
    await assertFails(getDoc(doc(db, 'inviteCodes/ABC123')));
  });

  it('그룹의 방장은 새 코드를 만들 수 있다', async () => {
    const db = asUser('alice').firestore();
    await assertSucceeds(
      setDoc(doc(db, 'inviteCodes/ZZZ999'), { groupId: 'g1' }),
    );
  });

  it('방장이 아니면 그 그룹을 가리키는 코드를 만들 수 없다', async () => {
    const db = asUser('bob').firestore();
    await assertFails(
      setDoc(doc(db, 'inviteCodes/ZZZ999'), { groupId: 'g1' }),
    );
  });

  it('이미 존재하는 코드는 덮어써서 다시 만들 수 없다(중복 방지)', async () => {
    const db = asUser('alice').firestore();
    await assertFails(
      setDoc(doc(db, 'inviteCodes/ABC123'), { groupId: 'g1' }),
    );
  });

  it('그룹의 방장은 기존 코드를 지울 수 있다(재발급용)', async () => {
    const db = asUser('alice').firestore();
    await assertSucceeds(deleteDoc(doc(db, 'inviteCodes/ABC123')));
  });

  it('방장이 아니면 남의 그룹 코드를 지울 수 없다', async () => {
    const db = asUser('bob').firestore();
    await assertFails(deleteDoc(doc(db, 'inviteCodes/ABC123')));
  });

  it('코드 문서는 수정할 수 없다', async () => {
    const db = asUser('alice').firestore();
    await assertFails(
      updateDoc(doc(db, 'inviteCodes/ABC123'), { groupId: 'other' }),
    );
  });
});
