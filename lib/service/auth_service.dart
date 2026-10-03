import '../model/usuario.dart';

abstract class AuthService {
  Usuario? get usuarioAtual;

  Future<Usuario> entrar({required String email, required String senha});

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  });

  Future<void> recuperarSenha(String email);

  Future<Usuario> atualizarPerfil({
    required String nome,
    required String telefone,
  });

  Future<void> sair();
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
