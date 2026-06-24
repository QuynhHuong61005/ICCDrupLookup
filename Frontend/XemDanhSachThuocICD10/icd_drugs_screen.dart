import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'icd_provider.dart';

class IcdDrugsScreen extends ConsumerWidget {
  final String icdId;
  final String token;

  const IcdDrugsScreen({
    Key? key,
    required this.icdId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icdDetailAsync = ref.watch(icdDetailProvider({'id': icdId, 'token': token}));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gợi ý thuốc theo bệnh', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: icdDetailAsync.when(
        data: (icdDetail) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã ICD-10: ${icdDetail.icdCode}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      const SizedBox(height: 8),
                      Text('Bệnh: ${icdDetail.diseaseName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Nhóm: ${icdDetail.diseaseGroup}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Danh sách thuốc gợi ý:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (icdDetail.recommendedDrugs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Không có thuốc gợi ý cho bệnh này.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: icdDetail.recommendedDrugs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final drug = icdDetail.recommendedDrugs[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(drug.brandName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                              const Divider(height: 24),
                              _buildInfoRow(Icons.science, 'Hoạt chất:', drug.activeIngredient),
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.medication, 'Liều dùng:', drug.standardDosage),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.health_and_safety, size: 20, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  const Text('BHYT: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text(
                                    drug.bhytStatus, 
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      color: drug.bhytStatus.toLowerCase().contains('có') ? Colors.green : Colors.red
                                    )
                                  ),
                                ],
                              ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
