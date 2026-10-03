import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../util/currency_utils.dart';
import '../util/date_utils.dart';
import '../widget/app_scope.dart';
import '../widget/empty_state.dart';
import '../widget/rateio_bottom_nav.dart';
import '../widget/section_card.dart';
import '../widget/summary_card.dart';
import 'registrar_pagamento_view.dart';

class PagamentosView extends StatelessWidget {
  const PagamentosView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final rateio = app.rateioSelecionado;
    final calculo = app.calculoSelecionado;

    if (rateio == null || calculo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pagamentos')),
        body: const EmptyState(
          icon: Icons.payments_outlined,
          title: 'Nenhum rateio selecionado',
          message: 'Selecione um rateio para visualizar os pagamentos.',
        ),
      );
    }

    final pagamentos = [...rateio.pagamentos]
      ..sort((a, b) => b.pagoEm.compareTo(a.pagoEm));
    final restante = rateio.valorTotalCentavos - calculo.totalConfirmado;
    final restanteSeguro = restante < 0 ? 0 : restante;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamentos'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Registrar pagamento',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const RegistrarPagamentoView()),
            ),
            icon: const Icon(Icons.add_card_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const RegistrarPagamentoView()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Pagamento'),
      ),
      bottomNavigationBar: const RateioBottomNav(currentIndex: 2),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: SummaryCard(
                  label: 'Pago',
                  value: formatarCentavos(calculo.totalConfirmado),
                  valueColor: AppTheme.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  label: 'Restante',
                  value: formatarCentavos(restanteSeguro),
                  valueColor: restanteSeguro > 0 ? AppTheme.warning : AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Histórico',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (pagamentos.isEmpty)
            const SectionCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Nenhum pagamento registrado ainda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.muted),
                ),
              ),
            )
          else
            ...pagamentos.map((pagamento) {
              final participante = rateio.participantes.firstWhere(
                (p) => p.id == pagamento.participanteId,
              );
              final mes = rateio.meses.firstWhere((m) => m.id == pagamento.mesId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SectionCard(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF102A1D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.check, color: AppTheme.success),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(participante.nome, style: const TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 3),
                            Text(
                              '${formatarMes(mes.data)} • ${_formatarData(pagamento.pagoEm)}',
                              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                            ),
                            if (pagamento.observacao.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 3),
                              Text(
                                pagamento.observacao,
                                style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            formatarCentavos(pagamento.valorCentavos),
                            style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w900),
                          ),
                          IconButton(
                            tooltip: 'Excluir pagamento',
                            onPressed: () => _confirmarExclusao(context, pagamento.id),
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.danger),
                          ),
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

  Future<void> _confirmarExclusao(BuildContext context, String pagamentoId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir pagamento?'),
        content: const Text('O registro será removido, mas o planejamento das parcelas permanecerá inalterado.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;
    await AppScope.of(context).excluirPagamento(pagamentoId);
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year} $hora:$minuto';
  }
}
