import 'package:flutter/material.dart';

import '../business/rateio_calculator.dart';
import '../model/mes_rateio.dart';
import '../model/pagamento.dart';
import '../model/participante.dart';
import '../model/rateio.dart';
import '../model/usuario.dart';
import '../service/auth_service.dart';
import '../service/rateio_service.dart';
import '../util/date_utils.dart';
import '../util/id_utils.dart';

class AppController extends ChangeNotifier {
  AppController({
    required AuthService authService,
    required RateioService rateioService,
  })  : _authService = authService,
        _rateioService = rateioService;

  final AuthService _authService;
  final RateioService _rateioService;
  final RateioCalculator _calculator = const RateioCalculator();

  Usuario? _usuario;
  List<Rateio> _rateios = <Rateio>[];
  String? _rateioSelecionadoId;
  bool _carregando = false;

  Usuario? get usuario => _usuario;
  List<Rateio> get rateios => List<Rateio>.unmodifiable(_rateios);
  bool get carregando => _carregando;
  bool get autenticado => _usuario != null;

  Rateio? get rateioSelecionado {
    if (_rateioSelecionadoId == null) return null;
    for (final rateio in _rateios) {
      if (rateio.id == _rateioSelecionadoId) return rateio;
    }
    return null;
  }

  RateioCalculation? get calculoSelecionado {
    final rateio = rateioSelecionado;
    if (rateio == null) return null;
    return _calculator.calcular(rateio);
  }

  RateioCalculation calcular(Rateio rateio) => _calculator.calcular(rateio);

  Future<String?> entrar({required String email, required String senha}) async {
    _setCarregando(true);
    try {
      _usuario = await _authService.entrar(email: email, senha: senha);
      await _carregarRateios();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Não foi possível entrar. Tente novamente.';
    } finally {
      _setCarregando(false);
    }
  }

  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    _setCarregando(true);
    try {
      _usuario = await _authService.cadastrar(
        nome: nome,
        email: email,
        telefone: telefone,
        senha: senha,
      );
      await _carregarRateios();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Não foi possível criar a conta.';
    } finally {
      _setCarregando(false);
    }
  }

  Future<String?> recuperarSenha(String email) async {
    _setCarregando(true);
    try {
      await _authService.recuperarSenha(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Não foi possível solicitar a recuperação.';
    } finally {
      _setCarregando(false);
    }
  }

  Future<String?> atualizarPerfil({
    required String nome,
    required String telefone,
  }) async {
    _setCarregando(true);
    try {
      _usuario = await _authService.atualizarPerfil(
        nome: nome,
        telefone: telefone,
      );
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Não foi possível atualizar o perfil.';
    } finally {
      _setCarregando(false);
    }
  }

  Future<void> sair() async {
    await _authService.sair();
    _usuario = null;
    _rateios = <Rateio>[];
    _rateioSelecionadoId = null;
    notifyListeners();
  }

  Future<void> _carregarRateios() async {
    final usuario = _usuario;
    if (usuario == null) return;
    _rateios = await _rateioService.listarPorUsuario(usuario.id);
    if (_rateios.isNotEmpty) {
      _rateioSelecionadoId = _rateios.first.id;
    } else {
      _rateioSelecionadoId = null;
    }
    notifyListeners();
  }

  void selecionarRateio(String rateioId) {
    if (_rateios.any((rateio) => rateio.id == rateioId)) {
      _rateioSelecionadoId = rateioId;
      notifyListeners();
    }
  }

  Future<Rateio> criarRateio({
    required String nome,
    required int valorTotalCentavos,
    required DateTime mesInicial,
    required DateTime mesFinal,
    required int capacidade,
  }) async {
    final usuario = _usuario;
    if (usuario == null) {
      throw StateError('Usuário não autenticado.');
    }

    final datas = mesesEntre(mesInicial, mesFinal);
    if (datas.isEmpty) {
      throw ArgumentError('Período inválido.');
    }

    final valores = distribuirValor(valorTotalCentavos, datas.length);
    final rateio = Rateio(
      id: IdUtils.next('rateio'),
      ownerId: usuario.id,
      nome: nome.trim(),
      valorTotalCentavos: valorTotalCentavos,
      capacidade: capacidade,
      meses: <MesRateio>[
        for (var i = 0; i < datas.length; i++)
          MesRateio(
            id: chaveMes(datas[i]),
            data: datas[i],
            valorDevidoCentavos: valores[i],
          ),
      ],
    );

    _rateios.add(rateio);
    _rateioSelecionadoId = rateio.id;
    await _rateioService.salvar(rateio);
    notifyListeners();
    return rateio;
  }

  Future<String?> adicionarParticipante({
    required String nome,
    required String mesInicialId,
    required String mesFinalId,
  }) async {
    final rateio = rateioSelecionado;
    if (rateio == null) return 'Nenhum rateio selecionado.';

    final ativos = rateio.participantes.where((p) => p.ativo).length;
    if (ativos >= rateio.capacidade) {
      return 'Capacidade máxima de ${rateio.capacidade} participantes atingida.';
    }
    if (!_periodoParticipanteValido(rateio, mesInicialId, mesFinalId)) {
      return 'O último mês não pode ser anterior ao mês inicial.';
    }

    rateio.participantes.add(
      Participante(
        id: IdUtils.next('p'),
        nome: nome.trim(),
        mesInicialId: mesInicialId,
        mesFinalId: mesFinalId,
      ),
    );
    await _salvarRateio(rateio);
    return null;
  }

  Future<String?> atualizarParticipante({
    required String participanteId,
    required String nome,
    required String mesInicialId,
    required String mesFinalId,
  }) async {
    final rateio = rateioSelecionado;
    if (rateio == null) return 'Nenhum rateio selecionado.';
    if (!_periodoParticipanteValido(rateio, mesInicialId, mesFinalId)) {
      return 'O último mês não pode ser anterior ao mês inicial.';
    }

    Participante? participante;
    for (final item in rateio.participantes) {
      if (item.id == participanteId) {
        participante = item;
        break;
      }
    }
    if (participante == null) return 'Participante não encontrado.';

    participante.nome = nome.trim();
    participante.mesInicialId = mesInicialId;
    participante.mesFinalId = mesFinalId;
    await _salvarRateio(rateio);
    return null;
  }

  bool participanteTemPagamentos(String participanteId) {
    final rateio = rateioSelecionado;
    if (rateio == null) return false;
    return rateio.pagamentos.any((p) => p.participanteId == participanteId);
  }

  Future<String?> excluirParticipante(String participanteId) async {
    final rateio = rateioSelecionado;
    if (rateio == null) return 'Nenhum rateio selecionado.';
    if (participanteTemPagamentos(participanteId)) {
      return 'Não é possível excluir uma pessoa que já possui pagamentos confirmados.';
    }
    rateio.participantes.removeWhere((p) => p.id == participanteId);
    await _salvarRateio(rateio);
    return null;
  }

  Future<String?> registrarPagamento({
    required String participanteId,
    required String mesId,
    required int valorCentavos,
    String observacao = '',
  }) async {
    final rateio = rateioSelecionado;
    if (rateio == null) return 'Nenhum rateio selecionado.';
    if (valorCentavos <= 0) return 'Informe um valor maior que zero.';
    if (!rateio.participantes.any((p) => p.id == participanteId)) {
      return 'Participante inválido.';
    }
    if (!rateio.meses.any((m) => m.id == mesId)) {
      return 'Mês inválido.';
    }

    rateio.pagamentos.add(
      Pagamento(
        id: IdUtils.next('pay'),
        participanteId: participanteId,
        mesId: mesId,
        valorCentavos: valorCentavos,
        pagoEm: DateTime.now(),
        observacao: observacao.trim(),
      ),
    );
    await _salvarRateio(rateio);
    return null;
  }

  Future<void> excluirPagamento(String pagamentoId) async {
    final rateio = rateioSelecionado;
    if (rateio == null) return;
    rateio.pagamentos.removeWhere((p) => p.id == pagamentoId);
    await _salvarRateio(rateio);
  }

  Future<String?> salvarConfiguracoesRateio({
    required String nome,
    required int valorTotalCentavos,
    required int capacidade,
    required Map<String, int> valoresPorMes,
    required bool concluido,
  }) async {
    final rateio = rateioSelecionado;
    if (rateio == null) return 'Nenhum rateio selecionado.';
    final ativos = rateio.participantes.where((p) => p.ativo).length;
    if (capacidade < ativos) {
      return 'A capacidade não pode ser menor que os $ativos participantes atuais.';
    }
    final soma = valoresPorMes.values.fold<int>(0, (a, b) => a + b);
    if (soma != valorTotalCentavos) {
      return 'A soma dos valores mensais precisa ser igual ao valor total.';
    }

    rateio.nome = nome.trim();
    rateio.valorTotalCentavos = valorTotalCentavos;
    rateio.capacidade = capacidade;
    rateio.concluido = concluido;
    for (final mes in rateio.meses) {
      mes.valorDevidoCentavos = valoresPorMes[mes.id] ?? mes.valorDevidoCentavos;
    }
    await _salvarRateio(rateio);
    return null;
  }

  Future<void> excluirRateioSelecionado() async {
    final rateio = rateioSelecionado;
    if (rateio == null) return;
    await _rateioService.excluir(rateio.id);
    _rateios.removeWhere((item) => item.id == rateio.id);
    _rateioSelecionadoId = _rateios.isEmpty ? null : _rateios.first.id;
    notifyListeners();
  }

  List<int> distribuirValor(int total, int quantidade) {
    if (quantidade <= 0) return <int>[];
    final base = total ~/ quantidade;
    final resto = total - (base * quantidade);
    return List<int>.generate(
      quantidade,
      (index) => base + (index < resto ? 1 : 0),
    );
  }

  bool _periodoParticipanteValido(
    Rateio rateio,
    String mesInicialId,
    String mesFinalId,
  ) {
    final inicio = rateio.meses.indexWhere((m) => m.id == mesInicialId);
    final fim = rateio.meses.indexWhere((m) => m.id == mesFinalId);
    return inicio >= 0 && fim >= 0 && inicio <= fim;
  }

  Future<void> _salvarRateio(Rateio rateio) async {
    await _rateioService.salvar(rateio);
    notifyListeners();
  }

  void _setCarregando(bool value) {
    if (_carregando == value) return;
    _carregando = value;
    notifyListeners();
  }
}

