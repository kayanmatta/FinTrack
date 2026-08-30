import 'package:intl/intl.dart';

/// Rótulo de exibição de um dia: 'Hoje', 'Ontem' ou 'dd/MM/yyyy'.
String dayLabel(DateTime day, {DateTime? reference}) {
  final ref = reference ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  final target = DateTime(day.year, day.month, day.day);
  final diff = today.difference(target).inDays;
  if (diff == 0) return 'Hoje';
  if (diff == 1) return 'Ontem';
  return DateFormat('dd/MM/yyyy').format(target);
}
