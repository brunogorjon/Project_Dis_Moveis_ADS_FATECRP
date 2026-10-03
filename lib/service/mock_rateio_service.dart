import '../model/mes_rateio.dart';
import '../model/pagamento.dart';
import '../model/participante.dart';
import '../model/rateio.dart';
import '../util/date_utils.dart';
import 'rateio_service.dart';

class MockRateioService implements RateioService {
  MockRateioService() {
    _rateios.add(_criarExemplo());
  }

  final List<Rateio> _rateios = <Rateio>[];

  @override
  Future<List<Rateio>> listarPorUsuario(String usuarioId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _rateios
        .where((rateio) => rateio.ownerId == usuarioId)
        .map((rateio) => rateio.deepCopy())
        .toList();
  }

  @override
  Future<void> salvar(Rateio rateio) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final index = _rateios.indexWhere((item) => item.id == rateio.id);
    if (index >= 0) {
      _rateios[index] = rateio.deepCopy();
    } else {
      _rateios.add(rateio.deepCopy());
    }
  }

  @override
  Future<void> excluir(String rateioId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _rateios.removeWhere((rateio) => rateio.id == rateioId);
  }

  Rateio _criarExemplo() {
    final inicio = inicioDoMes(DateTime.now());
    final datas = List<DateTime>.generate(6, (index) => adicionarMeses(inicio, index));
    const total = 600000;
    final valores = _distribuir(total, datas.length);
    final meses = <MesRateio>[
      for (var i = 0; i < datas.length; i++)
        MesRateio(
          id: chaveMes(datas[i]),
          data: datas[i],
          valorDevidoCentavos: valores[i],
        ),
    ];

    final participantes = <Participante>[
      Participante(
        id: 'p_demo_1',
        nome: 'Gabriel',
        mesInicialId: meses.first.id,
        mesFinalId: meses.last.id,
      ),
      Participante(
        id: 'p_demo_2',
        nome: 'João',
        mesInicialId: meses.first.id,
        mesFinalId: meses.last.id,
      ),
      Participante(
        id: 'p_demo_3',
        nome: 'Pedro',
        mesInicialId: meses.first.id,
        mesFinalId: meses.last.id,
      ),
      Participante(
        id: 'p_demo_4',
        nome: 'Lucas',
        mesInicialId: meses[2].id,
        mesFinalId: meses.last.id,
      ),
    ];

    final pagamentos = <Pagamento>[
      Pagamento(
        id: 'pay_demo_1',
        participanteId: 'p_demo_1',
        mesId: meses.first.id,
        valorCentavos: 50000,
        pagoEm: DateTime.now().subtract(const Duration(days: 12)),
        observacao: 'Primeira parcela',
      ),
      Pagamento(
        id: 'pay_demo_2',
        participanteId: 'p_demo_2',
        mesId: meses.first.id,
        valorCentavos: 50000,
        pagoEm: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    return Rateio(
      id: 'rateio_demo',
      ownerId: 'user_demo',
      nome: 'Viagem para a Praia',
      valorTotalCentavos: total,
      capacidade: 8,
      meses: meses,
      participantes: participantes,
      pagamentos: pagamentos,
    );
  }

  List<int> _distribuir(int total, int quantidade) {
    final base = total ~/ quantidade;
    final resto = total - (base * quantidade);
    return List<int>.generate(
      quantidade,
      (index) => base + (index < resto ? 1 : 0),
    );
  }
}
