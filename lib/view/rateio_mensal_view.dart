import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../util/currency_utils.dart';
import '../util/date_utils.dart';
import '../widget/app_scope.dart';
import '../widget/empty_state.dart';
import '../widget/rateio_bottom_nav.dart';
import '../widget/section_card.dart';
import 'registrar_pagamento_view.dart';

class RateioMensalView extends StatelessWidget {
  const RateioMensalView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final rateio = app.rateioSelecionado;
    final calculo = app.calculoSelecionado;

    if (rateio == null || calculo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rateio mensal')),
        body: const EmptyState(
          icon: Icons.calendar_month_outlined,
          title: 'Nenhum rateio selecionado',
          message: 'Selecione um rateio para visualizar o planejamento mensal.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rateio mensal')),
      bottomNavigationBar: const RateioBottomNav(currentIndex: 3),
      body: calculo.participantes.isEmpty
          ? const EmptyState(
              icon: Icons.calendar_month_outlined,
              title: 'Planejamento aguardando participantes',
              message: 'Adicione participantes para que as parcelas sejam calculadas.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: <Widget>[
                const Text(
                  'As parcelas são obrigações planejadas. Pagamentos atualizam o realizado, mas não redistribuem automaticamente as parcelas.',
                  style: TextStyle(color: AppTheme.muted, height: 1.4),
                ),
                const SizedBox(height: 16),
                ...rateio.meses.map((mes) {
                  final info = calculo.infoPorMes[mes.id]!;
                  final quitado = info.pendente == 0 && info.planejado > 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      padding: EdgeInsets.zero,
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                formatarMes(mes.data),
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            if (quitado)
                              const Icon(Icons.check_circle, color: AppTheme.success, size: 20)
                            else if (info.pendente > 0)
                              const Icon(Icons.schedule, color: AppTheme.warning, size: 20),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 14,
                            runSpacing: 5,
                            children: <Widget>[
                              Text('Compromisso ${formatarCentavos(info.devido)}', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                              Text('Planejado ${formatarCentavos(info.planejado)}', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                              Text('Pago ${formatarCentavos(info.confirmado)}', style: const TextStyle(color: AppTheme.success, fontSize: 12)),
                              if (info.pendente > 0)
                                Text('Pendente ${formatarCentavos(info.pendente)}', style: const TextStyle(color: AppTheme.warning, fontSize: 12)),
                            ],
                          ),
                        ),
                        children: <Widget>[
                          const Divider(),
                          ...calculo.participantes.map((participante) {
                            final planejado = calculo.valorPlanejado(participante.id, mes.id);
                            final pago = rateio.pagamentos
                                .where((p) => p.participanteId == participante.id && p.mesId == mes.id)
                                .fold<int>(0, (a, b) => a + b.valorCentavos);
                            final faltaBruta = planejado - pago;
                            final falta = faltaBruta > 0 ? faltaBruta : 0;
                            if (planejado == 0 && pago == 0) return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(participante.nome, style: const TextStyle(fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Previsto ${formatarCentavos(planejado)} • Pago ${formatarCentavos(pago)}',
                                          style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (falta > 0)
                                    TextButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (_) => RegistrarPagamentoView(
                                            participanteIdInicial: participante.id,
                                            mesIdInicial: mes.id,
                                          ),
                                        ),
                                      ),
                                      child: Text(formatarCentavos(falta)),
                                    )
                                  else
                                    const Icon(Icons.check, color: AppTheme.success),
                                ],
                              ),
                            );
                          }),
                          if (info.deficit > 0) ...<Widget>[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF35171B),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF6B2B32)),
                              ),
                              child: Text(
                                'Déficit acumulado após este mês: ${formatarCentavos(info.deficit)}',
                                style: const TextStyle(color: AppTheme.danger),
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
