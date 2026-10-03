import 'package:flutter/material.dart';

import '../model/rateio.dart';
import '../theme/app_theme.dart';
import '../util/currency_utils.dart';
import '../util/date_utils.dart';
import '../widget/app_scope.dart';
import '../widget/section_card.dart';

class ConfiguracoesRateioView extends StatefulWidget {
  const ConfiguracoesRateioView({super.key});

  @override
  State<ConfiguracoesRateioView> createState() => _ConfiguracoesRateioViewState();
}

class _ConfiguracoesRateioViewState extends State<ConfiguracoesRateioView> {
  final _nome = TextEditingController();
  final _total = TextEditingController();
  final _capacidade = TextEditingController();
  final Map<String, TextEditingController> _valoresMes = <String, TextEditingController>{};
  bool _inicializado = false;
  bool _concluido = false;
  bool _salvando = false;
  String? _erro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    final rateio = AppScope.of(context).rateioSelecionado;
    if (rateio == null) return;
    _carregar(rateio);
  }

  void _carregar(Rateio rateio) {
    _nome.text = rateio.nome;
    _total.text = centavosParaCampo(rateio.valorTotalCentavos);
    _capacidade.text = rateio.capacidade.toString();
    _concluido = rateio.concluido;
    for (final mes in rateio.meses) {
      _valoresMes[mes.id] = TextEditingController(
        text: centavosParaCampo(mes.valorDevidoCentavos),
      );
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _total.dispose();
    _capacidade.dispose();
    for (final controller in _valoresMes.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _redistribuir() {
    final rateio = AppScope.of(context).rateioSelecionado;
    final total = converterParaCentavos(_total.text);
    if (rateio == null || total == null || total <= 0) {
      setState(() => _erro = 'Informe um valor total válido antes de redistribuir.');
      return;
    }
    final valores = AppScope.of(context).distribuirValor(total, rateio.meses.length);
    for (var i = 0; i < rateio.meses.length; i++) {
      _valoresMes[rateio.meses[i].id]?.text = centavosParaCampo(valores[i]);
    }
    setState(() => _erro = null);
  }

  Future<void> _salvar() async {
    final rateio = AppScope.of(context).rateioSelecionado;
    if (rateio == null) return;
    final nome = _nome.text.trim();
    final total = converterParaCentavos(_total.text);
    final capacidade = int.tryParse(_capacidade.text.trim());

    if (nome.length < 3) {
      setState(() => _erro = 'Informe um nome com ao menos 3 caracteres.');
      return;
    }
    if (total == null || total <= 0) {
      setState(() => _erro = 'Informe um valor total válido.');
      return;
    }
    if (capacidade == null || capacidade <= 0) {
      setState(() => _erro = 'Informe uma capacidade válida.');
      return;
    }

    final valores = <String, int>{};
    for (final mes in rateio.meses) {
      final valor = converterParaCentavos(_valoresMes[mes.id]?.text ?? '');
      if (valor == null || valor < 0) {
        setState(() => _erro = 'Revise o valor de ${formatarMes(mes.data)}.');
        return;
      }
      valores[mes.id] = valor;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    final erro = await AppScope.of(context).salvarConfiguracoesRateio(
      nome: nome,
      valorTotalCentavos: total,
      capacidade: capacidade,
      valoresPorMes: valores,
      concluido: _concluido,
    );
    if (!mounted) return;
    setState(() {
      _salvando = false;
      _erro = erro;
    });
    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _excluirRateio() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir rateio?'),
        content: const Text('Participantes e pagamentos deste planejamento serão removidos. Esta ação não pode ser desfeita nesta versão local.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    await AppScope.of(context).excluirRateioSelecionado();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, 'meus_rateios', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final rateio = AppScope.of(context).rateioSelecionado;
    if (rateio == null) {
      return const Scaffold(body: Center(child: Text('Nenhum rateio selecionado.')));
    }

    final somaMensal = rateio.meses.fold<int>(0, (total, mes) {
      final valor = converterParaCentavos(_valoresMes[mes.id]?.text ?? '') ?? 0;
      return total + valor;
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações do rateio')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            TextField(
              controller: _nome,
              decoration: const InputDecoration(
                labelText: 'Nome do rateio',
                prefixIcon: Icon(Icons.luggage_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _total,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor total',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _capacidade,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Máximo de participantes',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _concluido,
              onChanged: (value) => setState(() => _concluido = value),
              title: const Text('Rateio concluído', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Marque quando o planejamento já estiver encerrado.'),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Compromissos mensais',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                TextButton.icon(
                  onPressed: _redistribuir,
                  icon: const Icon(Icons.balance_outlined),
                  label: const Text('Dividir igualmente'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'A soma dos meses precisa ser exatamente igual ao valor total do rateio.',
              style: TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ...rateio.meses.map(
              (mes) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _valoresMes[mes.id],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: formatarMes(mes.data),
                    prefixText: 'R\$ ',
                  ),
                ),
              ),
            ),
            SectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Soma mensal', style: TextStyle(fontWeight: FontWeight.w800)),
                  Text(
                    formatarCentavos(somaMensal),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: somaMensal == (converterParaCentavos(_total.text) ?? -1)
                          ? AppTheme.success
                          : AppTheme.warning,
                    ),
                  ),
                ],
              ),
            ),
            if (_erro != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(_erro!, style: const TextStyle(color: AppTheme.danger)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: const Text('SALVAR ALTERAÇÕES'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _excluirRateio,
              icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
              label: const Text('EXCLUIR RATEIO', style: TextStyle(color: AppTheme.danger)),
            ),
          ],
        ),
      ),
    );
  }
}
