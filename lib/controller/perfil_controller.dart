import 'package:flutter/material.dart';

import '../util/validators.dart';
import 'app_controller.dart';

class PerfilController extends ChangeNotifier {
  bool _carregando = false;
  String? _erro;

  bool get carregando => _carregando;
  String? get erro => _erro;

  Future<bool> salvar(
    AppController app, {
    required String nome,
    required String telefone,
  }) async {
    _erro = Validators.nome(nome);
    if (_erro != null) {
      notifyListeners();
      return false;
    }

    _carregando = true;
    notifyListeners();
    _erro = await app.atualizarPerfil(nome: nome, telefone: telefone);
    _carregando = false;
    notifyListeners();
    return _erro == null;
  }
}
