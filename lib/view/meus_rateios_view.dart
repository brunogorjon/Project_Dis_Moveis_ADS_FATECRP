import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widget/app_drawer.dart';
import '../widget/app_scope.dart';
import '../widget/empty_state.dart';
import '../widget/rateio_card.dart';

class MeusRateiosView extends StatelessWidget {
  const MeusRateiosView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final usuario = app.usuario;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Meus rateios'),
        actions: <Widget>[
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
        child: app.rateios.isEmpty
            ? EmptyState(
                icon: Icons.luggage_outlined,
                title: 'Nenhum rateio por aqui',
                message: 'Crie um planejamento, escolha o período até a viagem e acompanhe o grupo mês a mês.',
                action: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, 'criar_rateio'),
                  icon: const Icon(Icons.add),
                  label: const Text('CRIAR PRIMEIRO RATEIO'),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                children: <Widget>[
                  Text(
                    'Olá, ${usuario == null ? 'usuário' : usuario.nome.split(' ').first}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Selecione um planejamento ou crie uma nova viagem.',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                  const SizedBox(height: 22),
                  ...app.rateios.map(
                    (rateio) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: RateioCard(
                        rateio: rateio,
                        calculo: app.calcular(rateio),
                        onTap: () {
                          app.selecionarRateio(rateio.id);
                          Navigator.pushNamed(context, 'rateio_dashboard');
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
