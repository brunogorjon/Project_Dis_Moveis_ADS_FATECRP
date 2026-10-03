import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../util/currency_utils.dart';
import '../util/date_utils.dart';
import '../widget/app_scope.dart';
import '../widget/section_card.dart';
import '../widget/summary_card.dart';
import 'participante_form_view.dart';
import 'registrar_pagamento_view.dart';

class ParticipanteDetalhesView extends StatelessWidget {
  const ParticipanteDetalhesView({super.key, required this.participanteId});

  final String participanteId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final rateio = app.rateioSelecionado;
    final calculo = app.calculoSelecionado;
    if (rateio == null || calculo == null) {
      return const Scaffold(body: Center(child: Text('Nenhum rateio selecionado.')));
    }

    final participante = rateio.participantes.firstWhere((p) => p.id == participanteId);
    final cota = calculo.cotas[participante.id] ?? 0;
    final pago = calculo.pagoPorParticipante[participante.id] ?? 0;
    final restante = calculo.saldosRestantes[participante.id] ?? 0;
    final credito = calculo.creditos[participante.id] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(participante.nome),
        actions: <Widget>[
          IconButton(
            tooltip: 'Editar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ParticipanteFormView(participanteId: participante.id),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: SummaryCard(label: 'Cota total', value: formatarCentavos(cota))),
              const SizedBox(width: 10),
              Expanded(child: SummaryCard(label: 'Pago', value: formatarCentavos(pago), valueColor: AppTheme.success)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(child: SummaryCard(label: 'Restante', value: formatarCentavos(restante), valueColor: restante > 0 ? AppTheme.warning : AppTheme.success)),
              const SizedBox(width: 10),
              Expanded(child: SummaryCard(label: 'Crédito', value: formatarCentavos(credito), valueColor: credito > 0 ? const Color(0xFFC084FC) : AppTheme.muted)),
            ],
          ),
          const SizedBox(height: 22),
          Text('Linha do tempo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ...rateio.meses.map((mes) {
            final planejado = calculo.valorPlanejado(participante.id, mes.id);
            final pagoMes = rateio.pagamentos
                .where((p) => p.participanteId == participante.id && p.mesId == mes.id)
                .fold<int>(0, (a, b) => a + b.valorCentavos);
            final diferenca = planejado - pagoMes;
            final restanteMes = diferenca > 0 ? diferenca : 0;
            final foraPeriodo = rateio.meses.indexWhere((m) => m.id == mes.id) <
                    rateio.meses.indexWhere((m) => m.id == participante.mesInicialId) ||
                rateio.meses.indexWhere((m) => m.id == mes.id) >
                    rateio.meses.indexWhere((m) => m.id == participante.mesFinalId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(formatarMes(mes.data), style: const TextStyle(fontWeight: FontWeight.w900)),
                        if (foraPeriodo)
                          const Text('Fora do período', style: TextStyle(color: AppTheme.muted, fontSize: 12))
                        else if (restanteMes == 0 && planejado > 0)
                          const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 18,
                      runSpacing: 8,
                      children: <Widget>[
                        Text('Previsto: ${formatarCentavos(planejado)}', style: const TextStyle(color: AppTheme.muted)),
                        Text('Pago: ${formatarCentavos(pagoMes)}', style: const TextStyle(color: AppTheme.success)),
                        if (restanteMes > 0)
                          Text('Falta: ${formatarCentavos(restanteMes)}', style: const TextStyle(color: AppTheme.warning)),
                      ],
                    ),
                    if (!foraPeriodo && restanteMes > 0) ...<Widget>[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => RegistrarPagamentoView(
                                participanteIdInicial: participante.id,
                                mesIdInicial: mes.id,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.add_card_outlined),
                          label: const Text('Registrar pagamento'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
