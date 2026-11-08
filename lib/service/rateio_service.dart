import '../model/rateio.dart';

abstract class RateioService {
  Future<List<Rateio>> listarPorUsuario(String usuarioId);
  Future<void> salvar(Rateio rateio);
  Future<void> excluir(String rateioId);
}

class RateioConflitoException implements Exception {
  const RateioConflitoException();
}
