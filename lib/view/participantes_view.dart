import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../util/currency_utils.dart';
import '../util/date_utils.dart';
import '../widget/app_scope.dart';
import '../widget/empty_state.dart';
import '../widget/rateio_bottom_nav.dart';
import '../widget/section_card.dart';
import 'participante_detalhes_view.dart';
import 'participante_form_view.dart';

class ParticipantesView extends StatelessWidget {
  const ParticipantesView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final rateio = app.rateioSelecionado;
    final calculo = app.calculoSelecionado;

    if (rateio == null || calculo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Participantes')),
        body: const EmptyState(
          icon: Icons.groups_outlined,
          title: 'Nenhum rateio selecionado',
          message: 'Selecione um rateio antes de gerenciar participantes.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participantes'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Adicionar participante',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const ParticipanteFormView()),
            ),
            icon: const Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const ParticipanteFormView()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      bottomNavigationBar: const RateioBottomNav(currentIndex: 1),
      body: calculo.participantes.isEmpty
          ? const EmptyState(
              icon: Icons.groups_outlined,
              title: 'Ainda não há participantes',
              message: 'Adicione as pessoas do grupo e defina em quais meses cada uma participará do rateio.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: <Widget>[
                Text(
                  '${calculo.participantes.length} de ${rateio.capacidade} participantes',
                  style: const TextStyle(color: AppTheme.muted),
                ),
                const SizedBox(height: 14),
                ...calculo.participantes.map((participante) {
                  final cota = calculo.cotas[participante.id] ?? 0;
                  final pago = calculo.pagoPorParticipante[participante.id] ?? 0;
                  final restante = calculo.saldosRestantes[participante.id] ?? 0;
                  final inicio = rateio.meses.firstWhere((m) => m.id == participante.mesInicialId);
                  final fim = rateio.meses.firstWhere((m) => m.id == participante.mesFinalId);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ParticipanteDetalhesView(participanteId: participante.id),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const CircleAvatar(
                                backgroundColor: Color(0xFF10264A),
                                child: Icon(Icons.person_outline, color: AppTheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      participante.nome,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${formatarMesCurto(inicio.data)} → ${formatarMesCurto(fim.data)}',
                                      style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
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
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              Expanded(child: _Kpi(label: 'COTA', value: formatarCentavos(cota))),
                              Expanded(child: _Kpi(label: 'PAGO', value: formatarCentavos(pago), color: AppTheme.success)),
                              Expanded(child: _Kpi(label: 'FALTA', value: formatarCentavos(restante), color: restante > 0 ? AppTheme.warning : AppTheme.success)),
                            ],
                          ),
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

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ),
      ],
    );
  }
}
