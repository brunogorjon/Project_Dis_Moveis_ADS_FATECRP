import '../model/rateio.dart';
import '../model/participante.dart';
import '../util/currency_utils.dart';

class MesRateioInfo {
  const MesRateioInfo({
    required this.confirmado,
    required this.planejado,
    required this.pendente,
    required this.devido,
    required this.caixaAposMes,
    required this.deficit,
  });

  final int confirmado;
  final int planejado;
  final int pendente;
  final int devido;
  final int caixaAposMes;
  final int deficit;
}

class RateioCalculation {
  const RateioCalculation({
    required this.participantes,
    required this.cotas,
    required this.pagoPorParticipante,
    required this.pagoPorMes,
    required this.creditos,
    required this.creditosProjetados,
    required this.planejadoPorParticipante,
    required this.saldosRestantes,
    required this.plano,
    required this.infoPorMes,
    required this.avisos,
    required this.totalConfirmado,
    required this.totalDevido,
    required this.totalCreditos,
    required this.totalPlanejado,
    required this.caixaProjetadoFinal,
  });

  final List<Participante> participantes;
  final Map<String, int> cotas;
  final Map<String, int> pagoPorParticipante;
  final Map<String, int> pagoPorMes;
  final Map<String, int> creditos;
  final Map<String, int> creditosProjetados;
  final Map<String, int> planejadoPorParticipante;
  final Map<String, int> saldosRestantes;
  final Map<String, Map<String, int>> plano;
  final Map<String, MesRateioInfo> infoPorMes;
  final List<String> avisos;
  final int totalConfirmado;
  final int totalDevido;
  final int totalCreditos;
  final int totalPlanejado;
  final int caixaProjetadoFinal;

  int valorPlanejado(String participanteId, String mesId) {
    return plano[participanteId]?[mesId] ?? 0;
  }
}

class RateioCalculator {
  const RateioCalculator();

  List<Participante> _ativos(Rateio rateio) {
    return rateio.participantes.where((p) => p.ativo).toList();
  }

  int _indiceMes(Rateio rateio, String mesId) {
    return rateio.meses.indexWhere((m) => m.id == mesId);
  }

  Map<String, int> _pagoPorParticipante(Rateio rateio) {
    final resultado = <String, int>{
      for (final p in rateio.participantes) p.id: 0,
    };
    for (final pagamento in rateio.pagamentos) {
      resultado[pagamento.participanteId] =
          (resultado[pagamento.participanteId] ?? 0) + pagamento.valorCentavos;
    }
    return resultado;
  }

  Map<String, int> _pagoPorMes(Rateio rateio) {
    final resultado = <String, int>{
      for (final m in rateio.meses) m.id: 0,
    };
    for (final pagamento in rateio.pagamentos) {
      resultado[pagamento.mesId] =
          (resultado[pagamento.mesId] ?? 0) + pagamento.valorCentavos;
    }
    return resultado;
  }

  int totalPagoCelula(Rateio rateio, String participanteId, String mesId) {
    return rateio.pagamentos
        .where(
          (p) => p.participanteId == participanteId && p.mesId == mesId,
        )
        .fold(0, (total, p) => total + p.valorCentavos);
  }

  Map<String, int> distribuirCotas(
    int totalCentavos,
    List<Participante> participantes,
  ) {
    final resultado = <String, int>{};
    if (participantes.isEmpty) return resultado;

    final base = totalCentavos ~/ participantes.length;
    var resto = totalCentavos - (base * participantes.length);

    for (var i = 0; i < participantes.length; i++) {
      resultado[participantes[i].id] = base + (i < resto ? 1 : 0);
    }
    return resultado;
  }

  Map<String, int> _alocarPonderado(
    int total,
    List<_Candidate> candidatos,
  ) {
    final saida = <String, int>{
      for (final c in candidatos) c.id: 0,
    };

    var restante = total < 0 ? 0 : total;
    var grupo = candidatos.where((c) => c.capacidade > 0).toList();
    var guard = 0;

    while (restante > 0 && grupo.isNotEmpty && guard++ < 20) {
      final somaPesos = grupo.fold<double>(
        0,
        (total, c) => total + (c.peso > 0 ? c.peso : 1),
      );

      final propostas = <_Proposal>[];
      var usado = 0;

      for (final c in grupo) {
        final peso = c.peso > 0 ? c.peso : 1;
        final bruto = restante * (peso / somaPesos);
        final capacidadeRestante = c.capacidade - (saida[c.id] ?? 0);
        final piso = bruto.floor();
        final valor = capacidadeRestante < piso ? capacidadeRestante : piso;
        propostas.add(_Proposal(id: c.id, fracao: bruto - piso));
        saida[c.id] = (saida[c.id] ?? 0) + valor;
        usado += valor;
      }

      restante -= usado;
      if (restante <= 0) break;

      propostas.sort((a, b) => b.fracao.compareTo(a.fracao));
      var progrediu = false;

      for (final proposta in propostas) {
        if (restante <= 0) break;
        final candidato = grupo.firstWhere((c) => c.id == proposta.id);
        if ((saida[proposta.id] ?? 0) < candidato.capacidade) {
          saida[proposta.id] = (saida[proposta.id] ?? 0) + 1;
          restante--;
          progrediu = true;
        }
      }

      grupo = grupo
          .where((c) => (saida[c.id] ?? 0) < c.capacidade)
          .toList();

      if (!progrediu && usado == 0) break;
    }

    return saida;
  }

  _ScheduleResult _montarPlano(Rateio rateio) {
    final participantes = _ativos(rateio);
    final plano = <String, Map<String, int>>{
      for (final p in participantes) p.id: <String, int>{},
    };
    final avisos = <String>[];

    final inicio = <String, int>{
      for (final p in participantes) p.id: _indiceMes(rateio, p.mesInicialId),
    };
    final fim = <String, int>{
      for (final p in participantes) p.id: _indiceMes(rateio, p.mesFinalId),
    };

    // Mantém a mesma regra do projeto JS: o passado do plano fica congelado.
    // Quando alguém entra, somente o mês de entrada e os meses seguintes são
    // recalculados para o grupo que já participa naquele ponto do cronograma.
    for (var mesEvento = 0; mesEvento < rateio.meses.length; mesEvento++) {
      final entrantes = participantes
          .where((p) => inicio[p.id] == mesEvento)
          .toList();
      if (entrantes.isEmpty) continue;

      final grupo = participantes
          .where(
            (p) =>
                (inicio[p.id] ?? -1) >= 0 &&
                (inicio[p.id] ?? -1) <= mesEvento,
          )
          .toList();
      final cotas = distribuirCotas(rateio.valorTotalCentavos, grupo);

      for (final participante in grupo) {
        for (var i = mesEvento; i < rateio.meses.length; i++) {
          plano[participante.id]?.remove(rateio.meses[i].id);
        }
      }

      final saldos = <String, int>{};
      for (final participante in grupo) {
        var congeladoAntes = 0;
        for (var i = 0; i < mesEvento; i++) {
          congeladoAntes +=
              plano[participante.id]?[rateio.meses[i].id] ?? 0;
        }
        final saldo = (cotas[participante.id] ?? 0) - congeladoAntes;
        saldos[participante.id] = saldo < 0 ? 0 : saldo;
      }

      var caixaAcumulado = 0;
      for (var i = 0; i < mesEvento; i++) {
        final planejadoMes = grupo.fold<int>(
          0,
          (total, p) => total + (plano[p.id]?[rateio.meses[i].id] ?? 0),
        );
        caixaAcumulado += planejadoMes - rateio.meses[i].valorDevidoCentavos;
      }

      for (var i = mesEvento; i < rateio.meses.length; i++) {
        final mes = rateio.meses[i];
        final elegiveis = grupo.where((p) {
          final saldo = saldos[p.id] ?? 0;
          final inicioPessoa = inicio[p.id] ?? -1;
          final fimPessoa = fim[p.id] ?? -1;
          return saldo > 0 &&
              i >= (inicioPessoa > mesEvento ? inicioPessoa : mesEvento) &&
              i <= fimPessoa;
        }).toList();

        final obrigatorios = elegiveis
            .where((p) => fim[p.id] == i)
            .toList();

        final necessidadeMes = mes.valorDevidoCentavos - caixaAcumulado;
        final devidoNecessario = necessidadeMes < 0 ? 0 : necessidadeMes;
        final totalObrigatorio = obrigatorios.fold<int>(
          0,
          (total, p) => total + (saldos[p.id] ?? 0),
        );
        final capacidadeTotal = elegiveis.fold<int>(
          0,
          (total, p) => total + (saldos[p.id] ?? 0),
        );

        final alvoBase = devidoNecessario > totalObrigatorio
            ? devidoNecessario
            : totalObrigatorio;
        final alvoColeta = alvoBase < capacidadeTotal ? alvoBase : capacidadeTotal;

        var planejadoTotal = 0;

        for (final participante in obrigatorios) {
          final valor = saldos[participante.id] ?? 0;
          plano[participante.id]![mes.id] =
              (plano[participante.id]![mes.id] ?? 0) + valor;
          saldos[participante.id] = 0;
          planejadoTotal += valor;
        }

        var restante = alvoColeta - planejadoTotal;
        if (restante < 0) restante = 0;

        final outros = elegiveis
            .where(
              (p) =>
                  !obrigatorios.any((obrigatorio) => obrigatorio.id == p.id) &&
                  (saldos[p.id] ?? 0) > 0,
            )
            .toList();

        if (restante > 0 && outros.isNotEmpty) {
          final candidatos = outros.map((p) {
            final mesesCalculados = (fim[p.id] ?? i) - i + 1;
            final mesesRestantes = mesesCalculados < 1 ? 1 : mesesCalculados;
            final saldo = saldos[p.id] ?? 0;
            return _Candidate(
              id: p.id,
              capacidade: saldo,
              peso: saldo / mesesRestantes,
            );
          }).toList();

          final alocacao = _alocarPonderado(restante, candidatos);
          for (final participante in outros) {
            final valor = alocacao[participante.id] ?? 0;
            if (valor == 0) continue;
            plano[participante.id]![mes.id] =
                (plano[participante.id]![mes.id] ?? 0) + valor;
            saldos[participante.id] = (saldos[participante.id] ?? 0) - valor;
            planejadoTotal += valor;
          }
        }

        caixaAcumulado += planejadoTotal - mes.valorDevidoCentavos;
      }

      for (final participante in grupo) {
        final saldo = saldos[participante.id] ?? 0;
        if (saldo > 0) {
          avisos.add(
            '${participante.nome} ainda tem ${formatarCentavos(saldo)} sem mês disponível para pagamento.',
          );
        }
      }
    }

    return _ScheduleResult(plano: plano, avisos: avisos);
  }

  RateioCalculation calcular(Rateio rateio) {
    final participantes = _ativos(rateio);
    final cotas = distribuirCotas(rateio.valorTotalCentavos, participantes);
    final pagoPorParticipante = _pagoPorParticipante(rateio);
    final pagoPorMes = _pagoPorMes(rateio);
    final planoCalculado = _montarPlano(rateio);
    final plano = planoCalculado.plano;
    final avisos = <String>[...planoCalculado.avisos];
    final creditos = <String, int>{};
    final saldosRestantes = <String, int>{};
    final planejadoPorParticipante = <String, int>{};
    final creditosProjetados = <String, int>{};

    for (final participante in participantes) {
      final pago = pagoPorParticipante[participante.id] ?? 0;
      final cota = cotas[participante.id] ?? 0;
      final bruto = cota - pago;
      saldosRestantes[participante.id] = bruto < 0 ? 0 : bruto;
      creditos[participante.id] = bruto < 0 ? -bruto : 0;

      final planejado = rateio.meses.fold<int>(
        0,
        (total, mes) => total + (plano[participante.id]?[mes.id] ?? 0),
      );
      planejadoPorParticipante[participante.id] = planejado;
      final creditoProjetado = planejado - cota;
      creditosProjetados[participante.id] =
          creditoProjetado > 0 ? creditoProjetado : 0;
    }

    final infoPorMes = <String, MesRateioInfo>{};
    var caixaReal = 0;

    for (final mes in rateio.meses) {
      final confirmado = pagoPorMes[mes.id] ?? 0;
      final planejado = participantes.fold<int>(
        0,
        (total, p) => total + (plano[p.id]?[mes.id] ?? 0),
      );
      final pendente = participantes.fold<int>(0, (total, p) {
        final parcela = plano[p.id]?[mes.id] ?? 0;
        final pagoCelula = totalPagoCelula(rateio, p.id, mes.id);
        final falta = parcela - pagoCelula;
        return total + (falta > 0 ? falta : 0);
      });

      caixaReal += confirmado - mes.valorDevidoCentavos;
      infoPorMes[mes.id] = MesRateioInfo(
        confirmado: confirmado,
        planejado: planejado,
        pendente: pendente,
        devido: mes.valorDevidoCentavos,
        caixaAposMes: caixaReal,
        deficit: caixaReal < 0 ? -caixaReal : 0,
      );
    }

    final totalConfirmado = rateio.pagamentos.fold<int>(
      0,
      (total, pagamento) => total + pagamento.valorCentavos,
    );
    final totalDevido = rateio.meses.fold<int>(
      0,
      (total, mes) => total + mes.valorDevidoCentavos,
    );
    final totalCreditos = creditos.values.fold<int>(0, (a, b) => a + b);
    final totalPlanejado = participantes.fold<int>(
      0,
      (total, p) => total + (planejadoPorParticipante[p.id] ?? 0),
    );

    return RateioCalculation(
      participantes: participantes,
      cotas: cotas,
      pagoPorParticipante: pagoPorParticipante,
      pagoPorMes: pagoPorMes,
      creditos: creditos,
      creditosProjetados: creditosProjetados,
      planejadoPorParticipante: planejadoPorParticipante,
      saldosRestantes: saldosRestantes,
      plano: plano,
      infoPorMes: infoPorMes,
      avisos: avisos,
      totalConfirmado: totalConfirmado,
      totalDevido: totalDevido,
      totalCreditos: totalCreditos,
      totalPlanejado: totalPlanejado,
      caixaProjetadoFinal: totalPlanejado - totalDevido,
    );
  }
}

class _Candidate {
  const _Candidate({
    required this.id,
    required this.capacidade,
    required this.peso,
  });

  final String id;
  final int capacidade;
  final double peso;
}

class _Proposal {
  const _Proposal({required this.id, required this.fracao});

  final String id;
  final double fracao;
}

class _ScheduleResult {
  const _ScheduleResult({required this.plano, required this.avisos});

  final Map<String, Map<String, int>> plano;
  final List<String> avisos;
}
