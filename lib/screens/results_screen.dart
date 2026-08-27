import 'package:flutter/material.dart';
import '../models/faraiz_models.dart';

class ResultsScreen extends StatelessWidget {
  final FaraizCalculationOutput result;

  const ResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বণ্টন প্রতিবেদন ও ফলাফল', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Calculation Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF047857)),
                      const SizedBox(width: 8),
                      Text(
                        result.distributionType == 'awl'
                            ? 'আউল (العول) সমন্বিত বণ্টন'
                            : result.distributionType == 'radd'
                                ? 'রদ্দ (الرد) সমন্বিত বণ্টন'
                                : 'স্বাভাবিক হানাফি ফারায়েজ বণ্টন',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF065F46)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.distributionSummaryBn,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text('ওয়ারিশদের প্রাপ্য অংশ:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
            const SizedBox(height: 8),

            // Share Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.shares.length,
              itemBuilder: (context, index) {
                final share = result.shares[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${share.nameBn} (${share.count} জন)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('${share.percentage.toStringAsFixed(2)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF047857))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(share.ruleExplanationBn, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('জনপ্রতি অংশ: ${share.perPersonPercentage.toStringAsFixed(2)}%',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                            if (share.quranReference != null)
                              Text(share.quranReference!,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF047857), fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Blocked Heirs Section
            if (result.blockedHeirs.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('বঞ্চিত ওয়ারিশগণ (হজবে হির্মান):',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: result.blockedHeirs
                      .map((b) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.block, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${b.nameBn}: ${b.ruleExplanationBn}',
                                    style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}