import '../entities/transaction_entity.dart';

/// Contrato de acesso às transações (camada de domínio).
abstract class TransactionRepository {
  /// Todas as transações, mais recentes primeiro.
  Stream<List<TransactionEntity>> watchAll();

  /// Cria uma transação e retorna o id gerado.
  Future<int> create({
    required String type,
    required int amount,
    int? categoryId,
    int? accountId,
    required DateTime date,
    String? description,
  });

  /// Atualiza todos os campos de uma transação existente.
  Future<void> update(TransactionEntity transaction);

  /// Exclui a transação.
  Future<void> delete(int id);
}
