import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/rateio.dart';
import 'rateio_firestore_mapper.dart';
import 'rateio_service.dart';

class FirestoreRateioService implements RateioService {
  FirestoreRateioService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _mapper = const RateioFirestoreMapper();
  final Map<String, int> _revisoes = {};

  Stream<QuerySnapshot<Map<String, dynamic>>> acompanhar(String usuarioId) =>
      _firestore
          .collection('rateios')
          .where('ownerId', isEqualTo: usuarioId)
          .snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>> acompanharDocumento(
    String id,
  ) => _firestore.collection('rateios').doc(id).snapshots();

  Rateio selecionarDocumento(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw const FormatException('Rateio não encontrado.');
    final revisao = data['revisao'];
    if (revisao is! int || revisao < 1) {
      throw const FormatException('Revisão inválida.');
    }
    final rateio = _mapper.fromMap(doc.id, data);
    _revisoes[doc.id] = revisao;
    return rateio;
  }

  @override
  Future<List<Rateio>> listarPorUsuario(String usuarioId) async {
    final snapshot = await _firestore
        .collection('rateios')
        .where('ownerId', isEqualTo: usuarioId)
        .get(const GetOptions(source: Source.server));
    _revisoes.clear();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final revisao = data['revisao'];
      if (revisao is! int || revisao < 1) {
        throw const FormatException('Revisão inválida.');
      }
      _revisoes[doc.id] = revisao;
      return _mapper.fromMap(doc.id, data);
    }).toList();
  }

  @override
  Future<void> salvar(Rateio rateio) async {
    final ref = _firestore.collection('rateios').doc(rateio.id);
    final revisao = _revisoes[rateio.id];
    if (revisao == null) {
      await ref.set({..._mapper.toMap(rateio), 'revisao': 1});
      _revisoes[rateio.id] = 1;
      return;
    }
    await _firestore.runTransaction((tx) async {
      final atual = await tx.get(ref);
      if (!atual.exists || atual.data()?['revisao'] != revisao) {
        throw const RateioConflitoException();
      }
      tx.set(ref, {..._mapper.toMap(rateio), 'revisao': revisao + 1});
    });
    _revisoes[rateio.id] = revisao + 1;
  }

  @override
  Future<void> excluir(String rateioId) async {
    final ref = _firestore.collection('rateios').doc(rateioId);
    final revisao = _revisoes[rateioId];
    if (revisao == null) throw const RateioConflitoException();
    await _firestore.runTransaction((tx) async {
      final atual = await tx.get(ref);
      if (!atual.exists || atual.data()?['revisao'] != revisao) {
        throw const RateioConflitoException();
      }
      tx.delete(ref);
    });
    _revisoes.remove(rateioId);
  }
}
