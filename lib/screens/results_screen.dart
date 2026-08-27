import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/faraiz_models.dart';

class ResultsScreen extends StatelessWidget {
  final MirathCalculationResult result;

  const ResultsScreen({super.key, required this.result});

  final List<Color> _chartColors = const [
    Color(0xFF047857), // Emerald
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF10B981), // Light Green
    Color(0xFF6366F1), // Indigo
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF64748B), // Slate
  ];

  @override
  Widget build(BuildContext context) {
    final status = result.status;
    final isAul = status == 'aul';
    final isRadd = status == 'radd';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('বণ্টন প্রতিবেদন ও ফলাফল', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 850;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? (constraints.maxWidth - 800) / 2 : 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Status Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isAul
                        ? const Color(0xFFFFFBEB)
                        : (isRadd ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isAul
                          ? const Color(0xFFFDE68A)
                          : (isRadd ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAul ? Icons.warning_amber_rounded : (isRadd ? Icons.trending_up : Icons.check_circle_outline),
                        color: isAul ? const Color(0xFFD97706) : (isRadd ? const Color(0xFF059669) : const Color(0xFF0284C7)),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAul
                                  ? 'আউল (العول) সমন্বিত বণ্টন'
                                  : (isRadd ? 'রদ্দ (الرد) নীতিতে বর্ধিত বণ্টন' : 'স্বাভাবিক ফারদ ও আসাবা বণ্টন'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isAul ? const Color(0xFFB45309) : (isRadd ? const Color(0xFF047857) : const Color(0xFF1E293B)),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              result.statusExplanationBn,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Interactive Pie/Donut Chart & Valuation Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'উত্তরাধিকার বণ্টন অনুপাত চার্ট',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Donut Chart Canvas
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: CustomPaint(
                              painter: _DonutChartPainter(
                                results: result.heirResults,
                                colors: _chartColors,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('মোট বণ্টন', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    const Text('১০০%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                    Text('৳ ${(result.netDistributableValuation / 1000).toStringAsFixed(0)}K', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Legend List
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: result.heirResults.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final heir = entry.value;
                                final color = _chartColors[idx % _chartColors.length];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                                  child: Row(
                                    children: [
                                      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${heir.nameBn} (${heir.count} জন)',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${heir.percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Heir Breakdown Cards
                const Text(
                  'ওয়ারিশদের বিস্তারিত প্রাপ্য ও দলিল:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                ),
                const SizedBox(height: 8),

                ...result.heirResults.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final heir = entry.value;
                  final color = _chartColors[idx % _chartColors.length];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.06),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(backgroundColor: color, radius: 5),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${heir.nameBn} (${heir.count} জন)',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'মোট ${heir.percentage.toStringAsFixed(2)}%',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Card Body
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                heir.ruleExplanationBn,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
                              ),
                              if (heir.quranReference != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  heir.quranReference!,
                                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.green.shade800),
                                ),
                              ],
                              const Divider(height: 18),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildAssetColumn('নগদ টাকা', '৳ ${heir.cashShare.toStringAsFixed(0)}', Colors.green.shade700),
                                  _buildAssetColumn('জমি', '${heir.landShare.toStringAsFixed(2)} শতক', Colors.teal.shade700),
                                  _buildAssetColumn('স্বর্ণ', '${heir.goldShare.toStringAsFixed(2)} ভরি', Colors.amber.shade800),
                                  _buildAssetColumn('মোট মূল্য', '৳ ${heir.totalValuationShare.toStringAsFixed(0)}', const Color(0xFF047857)),
                                ],
                              ),

                              if (heir.count > 1) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('জনপ্রতি প্রাপ্য অংশ:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      Text(
                                        '${heir.perPersonPercentage.toStringAsFixed(2)}% (৳ ${(heir.totalValuationShare / heir.count).toStringAsFixed(0)})',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // 4. Blocked Heirs (Hajb)
                if (result.blockedHeirs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'বঞ্চিত ওয়ারিশগণ (হজবে হির্মান):',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: result.blockedHeirs.map((b) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.cancel, color: Colors.redAccent, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${b.nameBn}: ${b.ruleExplanationBn}',
                                  style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssetColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

// Custom Painter for Donut Chart
class _DonutChartPainter extends CustomPainter {
  final List<HeirShareResult> results;
  final List<Color> colors;

  _DonutChartPainter({required this.results, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 18.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < results.length; i++) {
      final heir = results[i];
      final sweepAngle = (heir.percentage / 100.0) * 2 * math.pi;

      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}