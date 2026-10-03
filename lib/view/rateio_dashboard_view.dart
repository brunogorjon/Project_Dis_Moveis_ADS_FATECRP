import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../util/currency_utils.dart';
import '../util/date_utils.dart';
import '../widget/app_drawer.dart';
import '../widget/app_scope.dart';
import '../widget/empty_state.dart';
import '../widget/rateio_bottom_nav.dart';
import '../widget/section_card.dart';
import '../widget/summary_card.dart';

class RateioDashboardView extends StatelessWidget {
  const RateioDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final rateio = app.rateioSelecionado;
    final calculo = app.calculoSelecionado;

    if (rateio == null || calculo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rateio')),
        body: const EmptyState(
          icon: Icons.luggage_outlined,
          title: 'Nenhum rateio selecionado',
          message: 'Volte para Meus Rateios e selecione um planejamento.',
        ),
      );
    }

    final diferenca = rateio.valorTotalCentavos - calculo.totalConfirmado;
    final restante = diferenca > 0 ? diferenca : 0;
    final progresso = rateio.valorTotalCentavos <= 0
        ? 0.0
        : (calculo.totalConfirmado / rateio.valorTotalCentavos)
            .clamp(0.0, 1.0)
            .toDouble();

    final proximoMes = rateio.meses.where((mes) {
      final info = calculo.infoPorMes[mes.id];
      return info != null && info.pendente > 0;
    }).firstOrNull;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(rateio.nome),
        actions: <Widget>[
          IconButton(
            tooltip: 'Configurações do rateio',
            onPressed: () => Navigator.pushNamed(context, 'configuracoes_rateio'),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      bottomNavigationBar: const RateioBottomNav(currentIndex: 0),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        children: <Widget>[
          Text(
            '${formatarMes(rateio.mesInicial)} → ${formatarMes(rateio.mesFinal)}',
            style: const TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = width >= 700 ? (width - 24) / 3 : (width - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  SizedBox(
                    width: itemWidth,
                    child: SummaryCard(
                      label: 'Valor total',
                      value: formatarCentavos(rateio.valorTotalCentavos),
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: SummaryCard(
                      label: 'Arrecadado',
                      value: formatarCentavos(calculo.totalConfirmado),
                      icon: Icons.check_circle_outline,
                      valueColor: AppTheme.success,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: SummaryCard(
                      label: 'Restante',
                      value: formatarCentavos(restante),
                      icon: Icons.timelapse,
                      valueColor: restante > 0 ? AppTheme.warning : AppTheme.success,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Progresso do rateio', style: TextStyle(fontWeight: FontWeight.w800)),
                    Text('${(progresso * 100).round()}%', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 9,
                    backgroundColor: AppTheme.surfaceAlt,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${calculo.participantes.length} participantes ativos de ${rateio.capacidade} vagas',
                  style: const TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (proximoMes != null)
            SectionCard(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10264A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.event_note_outlined, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Próximo mês com pendência', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                        const SizedBox(height: 3),
                        Text(formatarMes(proximoMes.data), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                        const SizedBox(height: 2),
                        Text(
                          'Pendente: ${formatarCentavos(calculo.infoPorMes[proximoMes.id]?.pendente ?? 0)}',
                          style: const TextStyle(color: AppTheme.warning),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (calculo.avisos.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
                      SizedBox(width: 8),
                      Text('Atenção', style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...calculo.avisos.map(
                    (aviso) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(aviso, style: const TextStyle(color: AppTheme.warning)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text(
            'Acessos rápidos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: <Widget>[
              _QuickAction(
                icon: Icons.groups_outlined,
                label: 'Participantes',
                onTap: () => Navigator.pushNamed(context, 'participantes'),
              ),
              _QuickAction(
                icon: Icons.payments_outlined,
                label: 'Pagamentos',
                onTap: () => Navigator.pushNamed(context, 'pagamentos'),
              ),
              _QuickAction(
                icon: Icons.calendar_month_outlined,
                label: 'Rateio mensal',
                onTap: () => Navigator.pushNamed(context, 'rateio_mensal'),
              ),
              _QuickAction(
                icon: Icons.settings_outlined,
                label: 'Configurações',
                onTap: () => Navigator.pushNamed(context, 'configuracoes_rateio'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: AppTheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
