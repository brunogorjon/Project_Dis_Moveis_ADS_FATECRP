import 'package:flutter/material.dart';

import '../business/rateio_calculator.dart';
import '../model/rateio.dart';
import '../theme/app_theme.dart';
import '../util/currency_utils.dart';
import '../util/date_utils.dart';
import 'section_card.dart';

class RateioCard extends StatelessWidget {
  const RateioCard({
    super.key,
    required this.rateio,
    required this.calculo,
    required this.onTap,
  });

  final Rateio rateio;
  final RateioCalculation calculo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = rateio.valorTotalCentavos;
    final pago = calculo.totalConfirmado;
    final progresso = total <= 0
        ? 0.0
        : (pago / total).clamp(0.0, 1.0).toDouble();

    return SectionCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF10264A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.beach_access_outlined, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      rateio.nome,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatarMesCurto(rateio.mesInicial)} → ${formatarMesCurto(rateio.mesFinal)}',
                      style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _StatusChip(concluido: rateio.concluido),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(child: _Value(label: 'TOTAL', value: formatarCentavos(total))),
              Expanded(child: _Value(label: 'ARRECADADO', value: formatarCentavos(pago))),
              Expanded(
                child: _Value(
                  label: 'PESSOAS',
                  value: '${calculo.participantes.length}/${rateio.capacidade}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 7,
              backgroundColor: AppTheme.surfaceAlt,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progresso * 100).round()}% arrecadado',
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.muted,
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.concluido});

  final bool concluido;

  @override
  Widget build(BuildContext context) {
    final color = concluido ? AppTheme.success : AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        border: Border.all(color: color.withOpacity(.35)),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        concluido ? 'Concluído' : 'Ativo',
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
      ),
    );
  }
}
