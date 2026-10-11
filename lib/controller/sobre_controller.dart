import 'package:flutter/material.dart';

class SobreController extends ChangeNotifier {
  String get nomeApp => 'Rateio de Viagem';
  String get versao => '1.0.0';
  String get objetivo =>
      'Organizar rateios de viagens e apartamentos, distribuindo valores entre participantes e acompanhando pagamentos ao longo dos meses.';

  List<String> get integrantes => const <String>[
    'Bruno Garcia Gorjon',
    'Victor Fernando Ferreira da Cruz',
  ];
}
