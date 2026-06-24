import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'drug_detail_provider.dart';

class DrugDetailScreen extends ConsumerWidget {
  final String drugId;
  final String token;

  const DrugDetailScreen({
    Key? key,
    required this.drugId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drugDetailAsync = ref.watch(drugDetailProvider({'id': drugId, 'token': token}));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thuốc', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: drugDetailAsync.when(
        data: (drugDetail) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(drugDetail.brandName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 12),
                      _buildInfoText('Hoạt chất:', drugDetail.activeIngredient),
                      const SizedBox(height: 8),
                      _buildInfoText('Hàm lượng:', drugDetail.concentration),
                      const SizedBox(height: 8),
                      _buildInfoText('Dạng bào chế:', drugDetail.dosageForm),
                      const SizedBox(height: 8),
                      _buildInfoText('Nhà sản xuất:', drugDetail.manufacturer),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Interactions Section
                const Text('Tương tác thuốc:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (drugDetail.interactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Không tìm thấy thông tin tương tác.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: drugDetail.interactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final interaction = drugDetail.interactions[index];
                      final isSevere = interaction.severity.toLowerCase().contains('chống chỉ định') || 
                                       interaction.severity.toLowerCase().contains('nghiêm trọng');
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isSevere ? Colors.red.shade300 : Colors.orange.shade300, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(isSevere ? Icons.warning : Icons.info_outline, 
                                       color: isSevere ? Colors.red : Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Tương tác với: ${interaction.otherDrugName}', 
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  const Text('Mức độ: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    interaction.severity,
                                    style: TextStyle(
                                      color: isSevere ? Colors.red : Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(interaction.description, style: const TextStyle(height: 1.4)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
