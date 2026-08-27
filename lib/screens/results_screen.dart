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
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('উত্তরাধিকার বণ্টন প্রতিবেদন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAul
                        ? const Color(0xFFFFFBEB)
                        : (isRadd ? const Color(0xFFECFDF5) : Colors.white),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isAul
                          ? const Color(0xFFFDE68A)
                          : (isRadd ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isAul
                              ? const Color(0xFFFEF3C7)
                              : (isRadd ? const Color(0xFFD1FAE5) : const Color(0xFFE0F2FE)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isAul ? Icons.warning_amber_rounded : (isRadd ? Icons.trending_up : Icons.check_circle_outline),
                          color: isAul ? const Color(0xFFD97706) : (isRadd ? const Color(0xFF059669) : const Color(0xFF0284C7)),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
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
                            const SizedBox(height: 3),
                            Text(
                              result.statusExplanationBn,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.3),
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
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
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
                            width: 135,
                            height: 135,
                            child: CustomPaint(
                              painter: _DonutChartPainter(
                                results: result.heirResults,
                                colors: _chartColors,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('মোট বণ্টন', style: TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    const Text('১০০%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                    Text('৳ ${(result.netDistributableValuation / 1000).toStringAsFixed(0)}K', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
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
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${heir.nameBn} (${heir.count} জন)',
                                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${heir.percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
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
                const SizedBox(height: 10),

                ...result.heirResults.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final heir = entry.value;
                  final color = _chartColors[idx % _chartColors.length];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(backgroundColor: color, radius: 6),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${heir.nameBn} (${heir.count} জন)',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Islamic Rule & Quranic Reference
                              Text(
                                heir.ruleExplanationBn,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                              ),
                              if (heir.quranReference != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: Text(
                                    '۞ ${heir.quranReference!} ۞',
                                    style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF065F46), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                              const Divider(height: 22, color: Color(0xFFF1F5F9)),

                              // Itemized Assets Breakdown
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
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('জনপ্রতি প্রাপ্য অংশ:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      Text(
                                        '${heir.perPersonPercentage.toStringAsFixed(2)}% (৳ ${(heir.totalValuationShare / heir.count).toStringAsFixed(0)})',
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
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
                  const SizedBox(height: 10),
                  const Text(
                    'বঞ্চিত ওয়ারিশগণ (হজবে হির্মান):',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFECDD3)),
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
                                  style: TextStyle(fontSize: 12.5, color: Colors.red.shade900, height: 1.3),
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
        Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

// Custom Painter for Donut Chart with Curved Endings
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
      ..strokeCap = StrokeCap.round;

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