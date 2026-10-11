import 'package:flutter/material.dart';

import '../controller/sobre_controller.dart';
import '../theme/app_theme.dart';
import '../widget/app_logo.dart';
import '../widget/section_card.dart';

class SobreView extends StatefulWidget {
  const SobreView({super.key});

  @override
  State<SobreView> createState() => _SobreViewState();
}

class _SobreViewState extends State<SobreView> {
  final _controller = SobreController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const Align(child: AppLogo(size: 76)),
          const SizedBox(height: 18),
          Text(
            _controller.nomeApp,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Versão ${_controller.versao}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 24),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Objetivo',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text(
                  _controller.objetivo,
                  style: const TextStyle(color: AppTheme.muted, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Equipe de desenvolvimento',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
                const SizedBox(height: 10),
                ..._controller.integrantes.map(
                  (nome) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.person_outline,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(nome)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Projeto acadêmico',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
                SizedBox(height: 8),
                Text(
                  'Aplicativo multiplataforma desenvolvido em Flutter/Dart como requisito para conclusão da disciplina de Desenvolvimento de Aplicativos Móveis da Faculdade de Tecnologia de Ribeirão Preto',
                  style: TextStyle(color: AppTheme.muted, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
