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

describe('groups/{groupId}', () => {
  before(setupTestEnv);
  after(teardownTestEnv);
  afterEach(clearData);

  describe('생성', () => {
    it('만드는 사람이 owner이자 유일한 멤버면 생성할 수 있다', async () => {
      const db = asUser('alice').firestore();
      await assertSucceeds(
        setDoc(doc(db, 'groups/g1'), {
          name: '연구실',
          inviteCode: 'ABC123',
          ownerId: 'alice',
          memberIds: ['alice'],
        }),
      );
    });

    it('ownerId가 본인이 아니면 생성할 수 없다', async () => {
      const db = asUser('alice').firestore();
      await assertFails(
        setDoc(doc(db, 'groups/g1'), {
          name: '연구실',
          inviteCode: 'ABC123',
          ownerId: 'bob',
          memberIds: ['alice'],
        }),
      );
    });

    it('memberIds에 본인 말고 다른 사람이 섞여 있으면 생성할 수 없다', async () => {
      const db = asUser('alice').firestore();
      await assertFails(
        setDoc(doc(db, 'groups/g1'), {
          name: '연구실',
          inviteCode: 'ABC123',
          ownerId: 'alice',
          memberIds: ['alice', 'bob'],
        }),
      );
    });

    it('로그인하지 않으면 그룹을 만들 수 없다', async () => {
      const db = asAnonymous().firestore();
      await assertFails(
        setDoc(doc(db, 'groups/g1'), {
          name: '연구실',
          inviteCode: 'ABC123',
          ownerId: 'ghost',
          memberIds: ['ghost'],
        }),
      );
    });
  });

  describe('읽기', () => {
    beforeEach(() =>
      seed((context) =>
        setDoc(doc(context.firestore(), 'groups/g1'), {
          name: '연구실',
          inviteCode: 'ABC123',
          ownerId: 'alice',
          memberIds: ['alice'],
        }),
      ),
    );

    it('멤버가 아니어도 로그인했으면 읽을 수 있다(참여 전 확인용)', async () => {
      const db = asUser('bob').firestore();
      await assertSucceeds(getDoc(doc(db, 'groups/g1')));
    });

    it('로그인하지 않으면 읽을 수 없다', async () => {
      const db = asAnonymous().firestore();
      await assertFails(getDoc(doc(db, 'groups/g1')));
    });
  });

  describe('가입(초대 코드로 참여)', () => {
    beforeEach(() =>
      seed((context) =>
        setDoc(doc(context.firestore(), 'groups/g1'), {
          name: '연구실',
          inviteCode: 'ABC123',
          ownerId: 'alice',
          memberIds: ['alice'],
        }),
      ),
    );

    it('아직 멤버가 아닌 사람이 자기 uid 하나만 추가하는 건 허용된다', async () => {
      const db = asUser('bob').firestore();
      await assertSucceeds(
        updateDoc(doc(db, 'groups/g1'), { memberIds: ['alice', 'bob'] }),
      );
    });

    it('이미 멤버인 사람은 다시 가입 요청을 보낼 수 없다', async () => {
      const db = asUser('alice').firestore();
      await assertFails(
        updateDoc(doc(db, 'groups/g1'), { memberIds: ['alice'] }),
      );
    });

    it('가입하면서 남을 같이 추가할 수는 없다', async () => {
      const db = asUser('bob').firestore();
      await assertFails(
        updateDoc(doc(db, 'groups/g1'), {
          memberIds: ['alice', 'bob', 'carol'],
        }),
      );
    });

    it('가입하면서 다른 필드(이름 등)를 같이 바꿀 수는 없다', async () => {
      const db = asUser('bob').firestore();
      await assertFails(
        updateDoc(doc(db, 'groups/g1'), {
          name: '해킹된 이름',
          memberIds: ['alice', 'bob'],
        }),
      );
    });
  });

  describe('그룹 멤버가 아니면 쓰기 거부', () => {
    beforeEach(() =>
      seed((context) =>
        setDoc(doc(context.firestore(), 'groups/g1'), {
          name: '연구실',
          inviteCode: 'ABC123',
          ownerId: 'alice',
          memberIds: ['alice'],
        }),
      ),
    );

    it('멤버도 아니고 가입/탈퇴/재발급 조건도 아니면 어떤 수정도 거부된다', async () => {
      const db = asUser('mallory').firestore();
      await assertFails(
        updateDoc(doc(db, 'groups/g1'), { name: '내가 바꿈' }),
      );
    });

    it('멤버가 아니면 그룹을 지울 수 없다', async () => {
      const db = asUser('mallory').firestore();
      await assertFails(deleteDoc(doc(db, 'groups/g1')));
    });
  });

  describe('탈퇴', () => {
    beforeEach(() =>
      seed((context) =>
        setDoc(doc(context.firestore(), 'groups/g1'), {
          name: '연구실',
          inviteCode: 'ABC123',
          ownerId: 'alice',
          memberIds: ['alice', 'bob'],
        }),
      ),
    );

    it('멤버(방장 아님)는 자기 uid 하나만 빼는 탈퇴가 가능하다', async () => {
      const db = asUser('bob').firestore();
      await assertSucceeds(
        updateDoc(doc(db, 'groups/g1'), { memberIds: ['alice'] }),
      );
    });

    it('방장은 탈퇴할 수 없다', async () => {
      const db = asUser('alice').firestore();
      await assertFails(
        updateDoc(doc(db, 'groups/g1'), { memberIds: ['bob'] }),
      );
    });

    it('탈퇴하면서 남의 uid까지 같이 뺄 수는 없다', async () => {
      const db = asUser('bob').firestore();
      await assertFails(updateDoc(doc(db, 'groups/g1'), { memberIds: [] }));
    });

    it('그룹에 속하지 않은 사람은 탈퇴 요청 자체가 거부된다', async () => {
      const db = asUser('mallory').firestore();
      await assertFails(
        updateDoc(doc(db, 'groups/g1'), { memberIds: ['alice', 'bob'] }),
      );
    });
  });

  describe('초대 코드 재발급', () => {
    beforeEach(() =>
      seed((context) =>
        setDoc(doc(context.firestore(), 'groups/g1'), {
          name: '연구실',
          inviteCode: 'ABC123',
          ownerId: 'alice',
          memberIds: ['alice', 'bob'],
        }),
      ),
    );

    it('방장은 초대 코드만 새 값으로 바꿀 수 있다', async () => {
      const db = asUser('alice').firestore();
      await assertSucceeds(
        updateDoc(doc(db, 'groups/g1'), { inviteCode: 'ZZZ999' }),
      );
    });

    it('방장이 아닌 멤버는 초대 코드를 재발급할 수 없다', async () => {
      const db = asUser('bob').firestore();
      await assertFails(
        updateDoc(doc(db, 'groups/g1'), { inviteCode: 'ZZZ999' }),
      );
    });

    it('같은 코드로는 재발급할 수 없다', async () => {
      const db = asUser('alice').firestore();
      await assertFails(
        updateDoc(doc(db, 'groups/g1'), { inviteCode: 'ABC123' }),
      );
    });

    it('코드 재발급과 다른 필드 변경을 같이 할 수는 없다', async () => {
      const db = asUser('alice').firestore();
      await assertFails(
        updateDoc(doc(db, 'groups/g1'), {
          inviteCode: 'ZZZ999',
          name: '몰래 바꾼 이름',
        }),
      );
    });
  });

  describe('삭제', () => {
    beforeEach(() =>
      seed((context) =>
        setDoc(doc(context.firestore(), 'groups/g1'), {
          name: '연구실',
          inviteCode: 'ABC123',
          ownerId: 'alice',
          memberIds: ['alice', 'bob'],
        }),
      ),
    );

    it('방장은 그룹을 삭제할 수 있다', async () => {
      const db = asUser('alice').firestore();
      await assertSucceeds(deleteDoc(doc(db, 'groups/g1')));
    });

    it('방장이 아닌 멤버는 그룹을 삭제할 수 없다', async () => {
      const db = asUser('bob').firestore();
      await assertFails(deleteDoc(doc(db, 'groups/g1')));
    });
  });
});
