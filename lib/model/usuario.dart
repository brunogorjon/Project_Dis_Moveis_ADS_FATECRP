class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
  });

  final String id;
  final String nome;
  final String email;
  final String telefone;

  Usuario copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
    );
  }
}
