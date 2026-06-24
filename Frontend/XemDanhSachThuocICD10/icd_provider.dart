import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'icd_repository.dart';
import 'icd_model.dart';

final icdRepositoryProvider = Provider((ref) => IcdRepository());

final icdDetailProvider = FutureProvider.family<IcdDetail, Map<String, String>>((ref, args) async {
  final repo = ref.watch(icdRepositoryProvider);
  final id = args['id']!;
  final token = args['token']!;
  return repo.getIcdDetail(id, token);
});
