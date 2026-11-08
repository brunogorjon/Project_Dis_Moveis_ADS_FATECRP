const fs = require('node:fs');
const { test, before, after } = require('node:test');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { doc, setDoc, getDoc, updateDoc, deleteDoc, collection, query, where, getDocs, Timestamp } = require('firebase/firestore');

let env;
let alice;
let bob;
let anonimo;
const agora = Timestamp.fromDate(new Date('2026-01-01T00:00:00Z'));
const rateio = { ownerId: 'alice', nome: 'Viagem', valorTotalCentavos: 10001, capacidade: 3, concluido: false, criadoEm: agora, meses: [{ id: 'm1' }], participantes: [], pagamentos: [], revisao: 1 };
const perfil = { nome: 'Alice', email: 'alice@example.com', telefone: '123', criadoEm: agora, atualizadoEm: agora };

before(async () => {
  env = await initializeTestEnvironment({ projectId: 'demo-rateio-regras', firestore: { rules: fs.readFileSync('firestore.rules', 'utf8') } });
  alice = env.authenticatedContext('alice', { email: 'alice@example.com' }).firestore();
  bob = env.authenticatedContext('bob', { email: 'bob@example.com' }).firestore();
  anonimo = env.unauthenticatedContext().firestore();
});
after(async () => { await env?.cleanup(); });

test('somente a dona cria e acessa o próprio perfil', async () => {
  await assertSucceeds(setDoc(doc(alice, 'usuarios/alice'), perfil));
  await assertSucceeds(getDoc(doc(alice, 'usuarios/alice')));
  await assertFails(getDoc(doc(bob, 'usuarios/alice')));
  await assertFails(updateDoc(doc(bob, 'usuarios/alice'), { nome: 'Outro' }));
  await assertFails(getDoc(doc(anonimo, 'usuarios/alice')));
});

test('isolamento de rateios e proteção do proprietário', async () => {
  const proprio = doc(alice, 'rateios/r1');
  await assertSucceeds(setDoc(proprio, rateio));
  await assertSucceeds(getDoc(proprio));
  await assertFails(getDoc(doc(bob, 'rateios/r1')));
  await assertFails(updateDoc(doc(bob, 'rateios/r1'), { nome: 'Invadido' }));
  await assertFails(deleteDoc(doc(bob, 'rateios/r1')));
  await assertFails(updateDoc(proprio, { ownerId: 'bob' }));
  await assertFails(setDoc(doc(bob, 'rateios/r2'), rateio));
  await assertFails(getDoc(doc(anonimo, 'rateios/r1')));
  await assertSucceeds(getDocs(query(collection(alice, 'rateios'), where('ownerId', '==', 'alice'))));
  await assertFails(getDocs(collection(alice, 'rateios')));
  await assertFails(updateDoc(proprio, { valorTotalCentavos: 1.5, revisao: 2 }));
  await assertFails(updateDoc(proprio, { nome: 'Versão antiga', revisao: 1 }));
  await assertSucceeds(updateDoc(proprio, { nome: 'Atualizado', revisao: 2 }));
  await assertSucceeds(deleteDoc(proprio));
});
