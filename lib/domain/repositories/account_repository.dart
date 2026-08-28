import '../entities/account_entity.dart';

/// Contrato de acesso às contas financeiras (camada de domínio).
abstract class AccountRepository {
  /// Todas as contas, reativamente.
  Stream<List<AccountEntity>> watchAll();

  /// Cria uma conta e retorna o id gerado.
  Future<int> create({
    required String name,
    required String type,
    required int initialBalance,
    required String color,
  });

  /// Atualiza os dados de uma conta existente.
  Future<void> update(AccountEntity account);

  /// Exclui a conta (transações vinculadas ficam sem conta).
  Future<void> delete(int id);
}
