/// Categoria de movimentação (camada de domínio).
class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
  });

  final int id;
  final String name;

  /// Nome do ícone (ver `core/utils/category_icons.dart`).
  final String icon;

  /// Cor no formato '#RRGGBB'.
  final String color;

  /// 'despesa' | 'receita'
  final String type;
  final bool isDefault;

  CategoryEntity copyWith({
    String? name,
    String? icon,
    String? color,
    String? type,
  }) {
    return CategoryEntity(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault,
    );
  }
}
