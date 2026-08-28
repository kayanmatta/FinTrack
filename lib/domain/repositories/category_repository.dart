import '../entities/category_entity.dart';

/// Contrato de acesso às categorias (camada de domínio).
abstract class CategoryRepository {
  /// Todas as categorias, reativamente.
  Stream<List<CategoryEntity>> watchAll();

  /// Cria uma categoria e retorna o id gerado.
  Future<int> create({
    required String name,
    required String icon,
    required String color,
    required String type,
  });

  /// Atualiza os dados de uma categoria existente.
  Future<void> update(CategoryEntity category);

  /// Exclui a categoria (transações vinculadas ficam sem categoria).
  Future<void> delete(int id);
}
