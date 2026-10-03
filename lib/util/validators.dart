class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static bool emailValido(String value) => _email.hasMatch(value.trim());

  static String? nome(String? value, {int minimo = 3}) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o nome.';
    if (texto.length < minimo) return 'O nome deve ter ao menos $minimo caracteres.';
    return null;
  }

  static String? email(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o e-mail.';
    if (!emailValido(texto)) return 'Informe um e-mail válido.';
    return null;
  }

  static String? senha(String? value, {int minimo = 6}) {
    final texto = value ?? '';
    if (texto.isEmpty) return 'Informe a senha.';
    if (texto.length < minimo) return 'A senha deve ter ao menos $minimo caracteres.';
    return null;
  }
}
