import '../entities/fixed_expense_entity.dart';

/// Contrato da camada de domínio para lançamentos fixos (S9).
///
/// Um lançamento fixo fica pendente a cada mês; [pay] o transforma em uma
/// transação real (que passa a contar no saldo e no extrato) e [unpay]
/// desfaz isso.
abstract class FixedExpenseRepository {
  /// Observa todos os lançamentos fixos cadastrados.
  Stream<List<FixedExpenseEntity>> watchAll();

  /// Observa todos os pagamentos confirmados.
  Stream<List<FixedExpensePaymentEntity>> watchPayments();

  /// Cria um lançamento fixo e retorna o id gerado.
  Future<int> create({
    required String type,
    required int amount,
    required int day,
    int? categoryId,
    int? accountId,
    String? description,
  });

  /// Atualiza um lançamento fixo existente (não afeta pagamentos já feitos).
  Future<void> update(FixedExpenseEntity expense);

  /// Exclui o lançamento fixo e o histórico de pagamentos dele.
  ///
  /// As transações já pagas permanecem no extrato.
  Future<void> delete(int id);

  /// Confirma o pagamento de [fixedId] no mês [month] ('yyyy-MM'), criando
  /// a transação real correspondente com o dia de vencimento do modelo.
  ///
  /// Ignora silenciosamente se o mês já estiver pago.
  Future<void> pay(int fixedId, {required String month});

  /// Desfaz o pagamento [paymentId], removendo também a transação criada.
  Future<void> unpay(int paymentId);
}
