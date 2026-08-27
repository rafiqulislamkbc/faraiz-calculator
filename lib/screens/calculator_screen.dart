import 'package:flutter/material.dart';
import '../models/faraiz_models.dart';
import '../services/hajb_rules_service.dart';
import '../services/hanafi_calculator_engine.dart';
import 'results_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  HeirInput _heirs = HeirInput();
  final AssetInput _assets = AssetInput();
  bool _autoFilter = true;

  Map<String, ExclusionInfo> get _hajbMap => HajbRulesService.evaluate(_heirs);

  void _calculateAndNavigate() {
    final result = HanafiCalculatorEngine.calculate(
      heirs: _heirs,
      assets: _assets,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(result: result),
      ),
    );
  }

  Widget _buildCounterCard(String key, String label, String sublabel, int value, ValueChanged<int> onChanged) {
    final isBlocked = _hajbMap[key]?.isExcluded ?? false;
    final blockedBy = _hajbMap[key]?.blockedByBn ?? '';

    if (_autoFilter && isBlocked) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isBlocked
            ? Colors.red.shade50.withValues(alpha: 0.6)
            : (value > 0 ? const Color(0xFFECFDF5) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBlocked
              ? Colors.red.shade200
              : (value > 0 ? const Color(0xFF047857) : Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    if (isBlocked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('বঞ্চিত ($blockedBy)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade800)),
                      ),
                    ]
                  ],
                ),
                Text(sublabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                onPressed: (!isBlocked && value > 0) ? () => onChanged(value - 1) : null,
              ),
              Container(
                width: 28,
                alignment: Alignment.center,
                child: Text('$value', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF047857), size: 22),
                onPressed: !isBlocked ? () => onChanged(value + 1) : null,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBinaryCard(String key, String label, String sublabel, int value, ValueChanged<int> onChanged) {
    final isBlocked = _hajbMap[key]?.isExcluded ?? false;
    final blockedBy = _hajbMap[key]?.blockedByBn ?? '';

    if (_autoFilter && isBlocked) {
      return const SizedBox.shrink();
    }

    final isSelected = value > 0;

    return InkWell(
      onTap: !isBlocked ? () => onChanged(isSelected ? 0 : 1) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isBlocked
              ? Colors.red.shade50.withValues(alpha: 0.6)
              : (isSelected ? const Color(0xFFECFDF5) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBlocked
                ? Colors.red.shade200
                : (isSelected ? const Color(0xFF047857) : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    if (isBlocked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('বঞ্চিত ($blockedBy)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade800)),
                      ),
                    ]
                  ],
                ),
                Text(sublabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF047857) : Colors.grey.shade400,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMale = _heirs.deceasedGender == 'male';

    return Scaffold(
      appBar: AppBar(
        title: const Text('হানাফি মিরাছ ও ফারায়েজ ক্যালকুলেটর', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_autoFilter ? Icons.filter_alt : Icons.filter_alt_off),
            tooltip: 'অটো হজব ফিল্টার',
            onPressed: () {
              setState(() {
                _autoFilter = !_autoFilter;
                if (_autoFilter) {
                  _heirs = HajbRulesService.sanitize(_heirs);
                }
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gender Selection
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Text('মরহুমের লিঙ্গ: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  ChoiceChip(
                    label: const Text('পুরুষ'),
                    selected: isMale,
                    selectedColor: const Color(0xFF047857),
                    labelStyle: TextStyle(color: isMale ? Colors.white : Colors.black),
                    onSelected: (v) {
                      setState(() {
                        _heirs.deceasedGender = 'male';
                        _heirs.husband = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('মহিলা'),
                    selected: !isMale,
                    selectedColor: Colors.purple.shade700,
                    labelStyle: TextStyle(color: !isMale ? Colors.white : Colors.black),
                    onSelected: (v) {
                      setState(() {
                        _heirs.deceasedGender = 'female';
                        _heirs.wives = 0;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 1: Spouse
            const Text('১. জীবনসঙ্গী', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
            const SizedBox(height: 6),
            if (isMale)
              _buildCounterCard('wives', 'স্ত্রী (Wife)', 'সর্বোচ্চ ৪ জন (১/৮ বা ১/৪)', _heirs.wives, (v) => setState(() => _heirs.wives = v))
            else
              _buildBinaryCard('husband', 'স্বামী (Husband)', '১/৪ বা ১/২ অংশ', _heirs.husband, (v) => setState(() => _heirs.husband = v)),

            const SizedBox(height: 14),

            // Section 2: Parents & Grandparents
            const Text('২. পিতা-মাতা ও দাদা-দাদি/নানি', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
            const SizedBox(height: 6),
            _buildBinaryCard('father', 'পিতা (Father)', '১/৬ বা আসাবা', _heirs.father, (v) => setState(() => _heirs.father = v)),
            _buildBinaryCard('mother', 'মাতা (Mother)', '১/৬ বা ১/৩', _heirs.mother, (v) => setState(() => _heirs.mother = v)),
            _buildBinaryCard('paternalGrandfather', 'দাদা (Grandfather)', 'পিতার অবর্তমানে', _heirs.paternalGrandfather, (v) => setState(() => _heirs.paternalGrandfather = v)),
            _buildBinaryCard('paternalGrandmother', 'দাদি (Pat. Grandmother)', 'পিতা/মাতার অবর্তমানে', _heirs.paternalGrandmother, (v) => setState(() => _heirs.paternalGrandmother = v)),
            _buildBinaryCard('maternalGrandmother', 'নানি (Mat. Grandmother)', 'মাতার অবর্তমানে', _heirs.maternalGrandmother, (v) => setState(() => _heirs.maternalGrandmother = v)),

            const SizedBox(height: 14),

            // Section 3: Children & Grandchildren
            const Text('৩. সন্তান ও পৌত্র-পৌত্রী', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
            const SizedBox(height: 6),
            _buildCounterCard('sons', 'পুত্র (Son)', 'আসাবা (কন্যার দ্বিগুণ)', _heirs.sons, (v) => setState(() => _heirs.sons = v)),
            _buildCounterCard('daughters', 'কন্যা (Daughter)', '১/২, ২/৩ বা আসাবা', _heirs.daughters, (v) => setState(() => _heirs.daughters = v)),
            _buildCounterCard('sonSons', 'পৌত্র (নাতি)', 'পুত্রের অবর্তমানে আসাবা', _heirs.sonSons, (v) => setState(() => _heirs.sonSons = v)),
            _buildCounterCard('sonDaughters', 'পৌত্রী (নাতনি)', 'পুত্রের অবর্তমানে', _heirs.sonDaughters, (v) => setState(() => _heirs.sonDaughters = v)),

            const SizedBox(height: 14),

            // Section 4: Siblings
            const Text('৪. ভাই-বোন', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
            const SizedBox(height: 6),
            _buildCounterCard('fullBrothers', 'সহোদর ভাই', 'আসাবা (২:১)', _heirs.fullBrothers, (v) => setState(() => _heirs.fullBrothers = v)),
            _buildCounterCard('fullSisters', 'সহোদর বোন', '১/২, ২/৩ বা আসাবা', _heirs.fullSisters, (v) => setState(() => _heirs.fullSisters = v)),
            _buildCounterCard('consanguineBrothers', 'বৈমাত্রেয় ভাই', 'পিতা এক, মাতা ভিন্ন', _heirs.consanguineBrothers, (v) => setState(() => _heirs.consanguineBrothers = v)),
            _buildCounterCard('consanguineSisters', 'বৈমাত্রেয় বোন', 'পিতা এক, মাতা ভিন্ন', _heirs.consanguineSisters, (v) => setState(() => _heirs.consanguineSisters = v)),
            _buildCounterCard('uterineBrothers', 'বৈপিত্রীয় ভাই', 'মাতা এক, পিতা ভিন্ন', _heirs.uterineBrothers, (v) => setState(() => _heirs.uterineBrothers = v)),
            _buildCounterCard('uterineSisters', 'বৈপিত্রীয় বোন', 'মাতা এক, পিতা ভিন্ন', _heirs.uterineSisters, (v) => setState(() => _heirs.uterineSisters = v)),

            const SizedBox(height: 14),

            // Section 5: Uncles & Cousins
            const Text('৫. ভাতিজা, চাচা ও চাচাতো ভাই', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
            const SizedBox(height: 6),
            _buildCounterCard('fullBrotherSons', 'সহোদর ভাতিজা', 'সহোদর ভাইয়ের ছেলে', _heirs.fullBrotherSons, (v) => setState(() => _heirs.fullBrotherSons = v)),
            _buildCounterCard('consanguineBrotherSons', 'বৈমাত্রেয় ভাতিজা', 'সৎ ভাইয়ের ছেলে', _heirs.consanguineBrotherSons, (v) => setState(() => _heirs.consanguineBrotherSons = v)),
            _buildCounterCard('fullPaternalUncles', 'সহোদর চাচা', 'পিতার সহোদর ভাই', _heirs.fullPaternalUncles, (v) => setState(() => _heirs.fullPaternalUncles = v)),
            _buildCounterCard('consanguinePaternalUncles', 'বৈমাত্রেয় চাচা', 'পিতার সৎ ভাই', _heirs.consanguinePaternalUncles, (v) => setState(() => _heirs.consanguinePaternalUncles = v)),
            _buildCounterCard('fullCousins', 'চাচাতো ভাই (সহোদর)', 'চাচার ছেলে', _heirs.fullCousins, (v) => setState(() => _heirs.fullCousins = v)),
            _buildCounterCard('consanguineCousins', 'চাচাতো ভাই (বৈমাত্রেয়)', 'সৎ চাচার ছেলে', _heirs.consanguineCousins, (v) => setState(() => _heirs.consanguineCousins = v)),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _calculateAndNavigate,
              icon: const Icon(Icons.calculate),
              label: const Text('হিসাব সম্পন্ন করুন (Calculate)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF047857),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}