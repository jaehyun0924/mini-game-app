const {
  doc,
  getDoc,
  addDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  collection,
} = require('firebase/firestore');
const {
  setupTestEnv,
  teardownTestEnv,
  clearData,
  seed,
  asUser,
  assertSucceeds,
  assertFails,
} = require('./helpers');

describe('groups/{groupId}/sessions/{sessionId}', () => {
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
      await setDoc(doc(db, 'groups/g1/sessions/s1'), {
        gameType: 'ladder',
        participants: ['앨리스', '밥'],
        result: {
          앨리스: { label: '커피 사기', isSpecial: true },
          밥: { label: '생존', isSpecial: false },
        },
        hostId: 'alice',
        createdAt: new Date(),
      });
    }),
  );

  it('그룹 멤버는 세션을 읽을 수 있다', async () => {
    const db = asUser('bob').firestore();
    await assertSucceeds(getDoc(doc(db, 'groups/g1/sessions/s1')));
  });

  it('그룹 멤버가 아니면 세션을 읽을 수 없다', async () => {
    const db = asUser('mallory').firestore();
    await assertFails(getDoc(doc(db, 'groups/g1/sessions/s1')));
  });

  it('멤버는 본인을 hostId로 하는 세션을 기록할 수 있다', async () => {
    const db = asUser('bob').firestore();
    await assertSucceeds(
      addDoc(collection(db, 'groups/g1/sessions'), {
        gameType: 'roulette',
        participants: ['앨리스', '밥'],
        result: {
          앨리스: { label: '당첨', isSpecial: true },
          밥: { label: '통과', isSpecial: false },
        },
        hostId: 'bob',
        createdAt: new Date(),
      }),
    );
  });

  it('그룹 멤버가 아니면 세션을 기록할 수 없다', async () => {
    const db = asUser('mallory').firestore();
    await assertFails(
      addDoc(collection(db, 'groups/g1/sessions'), {
        gameType: 'roulette',
        participants: ['맬러리'],
        result: { 맬러리: { label: '당첨', isSpecial: true } },
        hostId: 'mallory',
        createdAt: new Date(),
      }),
    );
  });

  it('hostId를 본인이 아닌 다른 사람으로 위조해서 기록할 수 없다', async () => {
    const db = asUser('bob').firestore();
    await assertFails(
      addDoc(collection(db, 'groups/g1/sessions'), {
        gameType: 'roulette',
        participants: ['앨리스', '밥'],
        result: {
          앨리스: { label: '당첨', isSpecial: true },
          밥: { label: '통과', isSpecial: false },
        },
        hostId: 'alice',
        createdAt: new Date(),
      }),
    );
  });

  it('세션을 만든 본인(host)도 나중에 결과를 수정할 수 없다(결과 조작 방지)', async () => {
    const db = asUser('alice').firestore();
    await assertFails(
      updateDoc(doc(db, 'groups/g1/sessions/s1'), {
        result: {
          앨리스: { label: '생존', isSpecial: false },
          밥: { label: '커피 사기', isSpecial: true },
        },
      }),
    );
  });

  it('본인이 만들지 않은 세션은 당연히 수정할 수 없다', async () => {
    const db = asUser('bob').firestore();
    await assertFails(
      updateDoc(doc(db, 'groups/g1/sessions/s1'), {
        result: {
          앨리스: { label: '생존', isSpecial: false },
          밥: { label: '커피 사기', isSpecial: true },
        },
      }),
    );
  });

  it('세션은 host를 포함해 아무도 삭제할 수 없다', async () => {
    const db = asUser('alice').firestore();
    await assertFails(deleteDoc(doc(db, 'groups/g1/sessions/s1')));
  });
});
