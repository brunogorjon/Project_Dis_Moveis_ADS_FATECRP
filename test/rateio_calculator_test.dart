import 'package:app_projeto/business/rateio_calculator.dart';
import 'package:app_projeto/model/mes_rateio.dart';
import 'package:app_projeto/model/pagamento.dart';
import 'package:app_projeto/model/participante.dart';
import 'package:app_projeto/model/rateio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = RateioCalculator();
  final participantes = [
    Participante(id: 'a', nome: 'Ana', mesInicialId: 'm1', mesFinalId: 'm1'),
    Participante(id: 'b', nome: 'Bia', mesInicialId: 'm1', mesFinalId: 'm1'),
    Participante(id: 'c', nome: 'Caio', mesInicialId: 'm1', mesFinalId: 'm1'),
  ];

  test('distribui centavos restantes sem perder valor', () {
    final cotas = calculator.distribuirCotas(10001, participantes);
    expect(cotas, {'a': 3334, 'b': 3334, 'c': 3333});
    expect(cotas.values.fold<int>(0, (a, b) => a + b), 10001);
  });

  test('pagamentos parciais e excedentes preservam saldo e crédito', () {
    final rateio = Rateio(
      id: 'r1',
      ownerId: 'u1',
      nome: 'Viagem',
      valorTotalCentavos: 10001,
      capacidade: 3,
      participantes: participantes,
      meses: [
        MesRateio(
          id: 'm1',
          data: DateTime.utc(2026, 1),
          valorDevidoCentavos: 10001,
        ),
      ],
      pagamentos: [
        Pagamento(
          id: 'p1',
          participanteId: 'a',
          mesId: 'm1',
          valorCentavos: 1000,
          pagoEm: DateTime.utc(2026),
        ),
        Pagamento(
          id: 'p2',
          participanteId: 'b',
          mesId: 'm1',
          valorCentavos: 4000,
          pagoEm: DateTime.utc(2026),
        ),
      ],
    );
    final result = calculator.calcular(rateio);
    expect(result.totalConfirmado, 5000);
    expect(result.saldosRestantes['a'], 2334);
    expect(result.creditos['b'], 666);
  });
}
