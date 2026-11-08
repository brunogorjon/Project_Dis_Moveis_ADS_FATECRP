import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/rateio.dart';
import '../service/rateio_firestore_mapper.dart';
import '../theme/app_theme.dart';
import '../widget/app_drawer.dart';
import '../widget/app_scope.dart';
import '../widget/empty_state.dart';
import '../widget/rateio_card.dart';

class MeusRateiosView extends StatefulWidget {
  const MeusRateiosView({super.key});

  @override
  State<MeusRateiosView> createState() => _MeusRateiosViewState();
}

class _MeusRateiosViewState extends State<MeusRateiosView> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppScope.of(context);
    if (_uid != app.usuario?.id) {
      _uid = app.usuario?.id;
      _stream = app.acompanharRateios();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Meus rateios'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () => Navigator.pushNamed(context, 'perfil'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, 'criar_rateio'),
        icon: const Icon(Icons.add),
        label: const Text('Novo rateio'),
      ),
      body: SafeArea(
        child: _stream == null
            ? _lista(context, app.rateios, (index) {
                app.selecionarRateio(app.rateios[index].id);
                Navigator.pushNamed(context, 'rateio_dashboard');
              })
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Não foi possível carregar os rateios.'),
                          TextButton(
                            onPressed: () => setState(
                              () => _stream = app.acompanharRateios(),
                            ),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  try {
                    const mapper = RateioFirestoreMapper();
                    final rateios = docs
                        .map((doc) => mapper.fromMap(doc.id, doc.data()))
                        .toList();
                    return _lista(context, rateios, (index) {
                      try {
                        app.selecionarRateioRemoto(docs[index]);
                        Navigator.pushNamed(context, 'rateio_dashboard');
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Não foi possível abrir este rateio.',
                            ),
                          ),
                        );
                      }
                    });
                  } catch (_) {
                    return const Center(
                      child: Text(
                        'Não foi possível interpretar os dados dos rateios.',
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }

  Widget _lista(
    BuildContext context,
    List<Rateio> rateios,
    void Function(int) abrir,
  ) {
    final app = AppScope.of(context);
    if (rateios.isEmpty) {
      return EmptyState(
        icon: Icons.luggage_outlined,
        title: 'Nenhum rateio por aqui',
        message:
            'Crie um planejamento, escolha o período até a viagem e acompanhe o grupo mês a mês.',
        action: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, 'criar_rateio'),
          icon: const Icon(Icons.add),
          label: const Text('CRIAR PRIMEIRO RATEIO'),
        ),
      );
    }
    final nome = app.usuario?.nome.split(' ').first ?? 'usuário';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      children: [
        Text(
          'Olá, $nome!',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        const Text(
          'Selecione um planejamento ou crie uma nova viagem.',
          style: TextStyle(color: AppTheme.muted),
        ),
        const SizedBox(height: 22),
        for (var i = 0; i < rateios.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: RateioCard(
              rateio: rateios[i],
              calculo: app.calcular(rateios[i]),
              onTap: () => abrir(i),
            ),
          ),
      ],
    );
  }
}
