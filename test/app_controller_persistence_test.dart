import 'package:app_projeto/controller/app_controller.dart';
import 'package:app_projeto/model/rateio.dart';
import 'package:app_projeto/service/mock_auth_service.dart';
import 'package:app_projeto/service/rateio_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FailingRateioService implements RateioService {
  bool falhar = false;
  final List<Rateio> dados = [];

  @override
  Future<List<Rateio>> listarPorUsuario(String usuarioId) async => dados
      .where((r) => r.ownerId == usuarioId)
      .map((r) => r.deepCopy())
      .toList();

  @override
  Future<void> salvar(Rateio rateio) async {
    if (falhar) throw StateError('falha simulada');
    dados.removeWhere((r) => r.id == rateio.id);
    dados.add(rateio.deepCopy());
  }

  @override
  Future<void> excluir(String rateioId) async {
    if (falhar) throw StateError('falha simulada');
    dados.removeWhere((r) => r.id == rateioId);
  }
}

void main() {
  test('falha ao criar ou alterar não modifica o estado confirmado', () async {
    final service = FailingRateioService();
    final controller = AppController(
      authService: MockAuthService(),
      rateioService: service,
    );
    expect(
      await controller.entrar(email: 'demo@rateio.app', senha: '123456'),
      isNull,
    );
    service.falhar = true;
    await expectLater(
      controller.criarRateio(
        nome: 'Viagem',
        valorTotalCentavos: 1000,
        mesInicial: DateTime(2026, 1),
        mesFinal: DateTime(2026, 1),
        capacidade: 2,
      ),
      throwsStateError,
    );
    expect(controller.rateios, isEmpty);
    service.falhar = false;
    final rateio = await controller.criarRateio(
      nome: 'Viagem',
      valorTotalCentavos: 1000,
      mesInicial: DateTime(2026, 1),
      mesFinal: DateTime(2026, 1),
      capacidade: 2,
    );
    service.falhar = true;
    final erro = await controller.adicionarParticipante(
      nome: 'Ana',
      mesInicialId: rateio.meses.first.id,
      mesFinalId: rateio.meses.first.id,
    );
    expect(erro, isNotNull);
    expect(controller.rateioSelecionado!.participantes, isEmpty);
    controller.dispose();
  });
}
