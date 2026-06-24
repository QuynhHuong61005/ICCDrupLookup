import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'drug_detail_repository.dart';
import 'drug_detail_model.dart';

final drugDetailRepositoryProvider = Provider((ref) => DrugDetailRepository());

final drugDetailProvider = FutureProvider.family<DrugDetail, Map<String, String>>((ref, args) async {
  final repo = ref.watch(drugDetailRepositoryProvider);
  final id = args['id']!;
  final token = args['token']!;
  return repo.getDrugDetail(id, token);
});
