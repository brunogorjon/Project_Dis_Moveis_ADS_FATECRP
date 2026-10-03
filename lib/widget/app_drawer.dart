import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_scope.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final usuario = app.usuario;

    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryStrong,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          usuario?.nome ?? 'Usuário',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          usuario?.email ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Meus rateios'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'meus_rateios',
                  (route) => false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'perfil');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Sobre'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'sobre');
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.danger),
              title: const Text('Sair'),
              onTap: () async {
                await app.sair();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'login',
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
