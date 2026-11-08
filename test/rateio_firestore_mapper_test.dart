import 'package:app_projeto/model/mes_rateio.dart';
import 'package:app_projeto/model/pagamento.dart';
import 'package:app_projeto/model/participante.dart';
import 'package:app_projeto/model/rateio.dart';
import 'package:app_projeto/service/rateio_firestore_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = RateioFirestoreMapper();
  final data = DateTime.utc(2026, 1, 15);
  final original = Rateio(
    id: 'r1',
    ownerId: 'u1',
    nome: 'Viagem',
    valorTotalCentavos: 10001,
    capacidade: 3,
    concluido: true,
    criadoEm: data,
    meses: [MesRateio(id: 'm1', data: data, valorDevidoCentavos: 10001)],
    participantes: [
      Participante(
        id: 'p1',
        nome: 'Ana',
        mesInicialId: 'm1',
        mesFinalId: 'm1',
        ativo: false,
        criadoEm: data,
      ),
    ],
    pagamentos: [
      Pagamento(
        id: 'pg1',
        participanteId: 'p1',
        mesId: 'm1',
        valorCentavos: 123,
        pagoEm: data,
        observacao: 'parcial',
      ),
    ],
  );

  test('preserva todos os campos no round-trip', () {
    final resultado = mapper.fromMap(original.id, mapper.toMap(original));
    expect(resultado.id, original.id);
    expect(mapper.toMap(resultado), mapper.toMap(original));
    expect(resultado.valorTotalCentavos, 10001);
    expect(resultado.pagamentos.single.valorCentavos, 123);
  });

  test('aceita campos opcionais ausentes', () {
    final map = mapper.toMap(original)
      ..remove('participantes')
      ..remove('pagamentos')
      ..remove('concluido');
    final resultado = mapper.fromMap('r1', map);
    expect(resultado.participantes, isEmpty);
    expect(resultado.pagamentos, isEmpty);
    expect(resultado.concluido, isFalse);
  });

  test('rejeita valor monetário que não seja inteiro', () {
    final map = mapper.toMap(original)..['valorTotalCentavos'] = 1.5;
    expect(() => mapper.fromMap('r1', map), throwsFormatException);
  });

  test('rejeita documento sem meses', () {
    final map = mapper.toMap(original)..['meses'] = [];
    expect(() => mapper.fromMap('r1', map), throwsFormatException);
  });
}
