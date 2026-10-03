import 'package:flutter/material.dart';

class SobreController extends ChangeNotifier {
  String get nomeApp => 'Rateio de Viagem';
  String get versao => '1.0.0';
  String get objetivo =>
      'Organizar rateios de viagens e apartamentos, distribuindo valores entre participantes e acompanhando pagamentos ao longo dos meses.';

  // Preencha antes da entrega final.
  List<String> get integrantes => const <String>[
        'Nome do integrante 1',
        'Nome do integrante 2',
      ];
}
