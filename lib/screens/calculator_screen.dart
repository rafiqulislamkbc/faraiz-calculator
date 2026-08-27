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

class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HeirInput _heirs = HeirInput();
  final AssetInput _assets = AssetInput();
  bool _autoFilter = true;

  // Asset Text Controllers for Live Typing
  late TextEditingController _cashCtrl;
  late TextEditingController _landCtrl;
  late TextEditingController _landPriceCtrl;
  late TextEditingController _goldCtrl;
  late TextEditingController _goldPriceCtrl;
  late TextEditingController _silverCtrl;
  late TextEditingController _silverPriceCtrl;
  late TextEditingController _otherAssetsCtrl;
  late TextEditingController _funeralCtrl;
  late TextEditingController _debtsCtrl;
  late TextEditingController _wasiyyahCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cashCtrl = TextEditingController(text: _assets.cashMoney.toStringAsFixed(0));
    _landCtrl = TextEditingController(text: _assets.landDecimals.toStringAsFixed(1));
    _landPriceCtrl = TextEditingController(text: _assets.landPricePerDecimal.toStringAsFixed(0));
    _goldCtrl = TextEditingController(text: _assets.goldBhori.toStringAsFixed(1));
    _goldPriceCtrl = TextEditingController(text: _assets.goldPricePerBhori.toStringAsFixed(0));
    _silverCtrl = TextEditingController(text: _assets.silverBhori.toStringAsFixed(1));
    _silverPriceCtrl = TextEditingController(text: _assets.silverPricePerBhori.toStringAsFixed(0));
    _otherAssetsCtrl = TextEditingController(text: _assets.otherAssetsVal.toStringAsFixed(0));
    _funeralCtrl = TextEditingController(text: _assets.funeralCost.toStringAsFixed(0));
    _debtsCtrl = TextEditingController(text: _assets.debtsAndMahr.toStringAsFixed(0));
    _wasiyyahCtrl = TextEditingController(text: _assets.wasiyyah.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashCtrl.dispose();
    _landCtrl.dispose();
    _landPriceCtrl.dispose();
    _goldCtrl.dispose();
    _goldPriceCtrl.dispose();
    _silverCtrl.dispose();
    _silverPriceCtrl.dispose();
    _otherAssetsCtrl.dispose();
    _funeralCtrl.dispose();
    _debtsCtrl.dispose();
    _wasiyyahCtrl.dispose();
    super.dispose();
  }

  Map<String, ExclusionInfo> get _hajbMap => HajbRulesService.evaluate(_heirs);

  int get _totalHeirsCount {
    return _heirs.husband +
        _heirs.wives +
        _heirs.father +
        _heirs.mother +
        _heirs.paternalGrandfather +
        _heirs.paternalGrandmother +
        _heirs.maternalGrandmother +
        _heirs.sons +
        _heirs.daughters +
        _heirs.sonSons +
        _heirs.sonDaughters +
        _heirs.fullBrothers +
        _heirs.fullSisters +
        _heirs.consanguineBrothers +
        _heirs.consanguineSisters +
        _heirs.uterineBrothers +
        _heirs.uterineSisters +
        _heirs.fullBrotherSons +
        _heirs.consanguineBrotherSons +
        _heirs.fullPaternalUncles +
        _heirs.consanguinePaternalUncles +
        _heirs.fullCousins +
        _heirs.consanguineCousins;
  }

  double get _grossValuation {
    final land = _assets.landDecimals * _assets.landPricePerDecimal;
    final gold = _assets.goldBhori * _assets.goldPricePerBhori;
    final silver = _assets.silverBhori * _assets.silverPricePerBhori;
    return land + gold + silver + _assets.cashMoney + _assets.otherAssetsVal;
  }

  double get _totalDeductions {
    final afterFuneral = _grossValuation > _assets.funeralCost ? _grossValuation - _assets.funeralCost : 0.0;
    final debtDeducted = _assets.debtsAndMahr > afterFuneral ? afterFuneral : _assets.debtsAndMahr;
    final afterDebt = afterFuneral > debtDeducted ? afterFuneral - debtDeducted : 0.0;
    final maxWasiyyah = afterDebt / 3.0;
    final wasiyyahDeducted = _assets.wasiyyah > maxWasiyyah ? maxWasiyyah : _assets.wasiyyah;
    return _assets.funeralCost + debtDeducted + wasiyyahDeducted;
  }

  double get _netDistributableValuation {
    final net = _grossValuation - _totalDeductions;
    return net > 0 ? net : 0.0;
  }

  void _calculateAndNavigate() {
    if (_totalHeirsCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে অন্তত একজন ওয়ারিশ নির্বাচন করুন।'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

  void _applyPreset(String preset) {
    setState(() {
      _heirs = HeirInput();
      if (preset == 'preset1') {
        _heirs.deceasedGender = 'male';
        _heirs.wives = 1;
        _heirs.father = 1;
        _heirs.mother = 1;
        _heirs.sons = 1;
        _heirs.daughters = 2;
      } else if (preset == 'preset2') {
        _heirs.deceasedGender = 'male';
        _heirs.wives = 1;
        _heirs.daughters = 3;
        _heirs.fullBrothers = 1;
      } else if (preset == 'preset3') {
        _heirs.deceasedGender = 'female';
        _heirs.husband = 1;
        _heirs.mother = 1;
        _heirs.fullSisters = 2;
      }
      if (_autoFilter) {
        _heirs = HajbRulesService.sanitize(_heirs);
      }
    });
  }

  Widget _buildCounterCard(String key, String label, String sublabel, int value, ValueChanged<int> onChanged) {
    final isBlocked = _hajbMap[key]?.isExcluded ?? false;
    final blockedBy = _hajbMap[key]?.blockedByBn ?? '';

    if (isBlocked && _autoFilter) {
      return const SizedBox.shrink();
    }

    final bool isSelected = value > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isBlocked
            ? Colors.red.shade50
            : (isSelected ? const Color(0xFFF0FDF4) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBlocked
              ? Colors.red.shade200
              : (isSelected ? const Color(0xFF047857) : Colors.grey.shade200),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isBlocked ? Colors.grey.shade700 : (isSelected ? const Color(0xFF065F46) : const Color(0xFF1E293B)),
                        ),
                      ),
                    ),
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
                const SizedBox(height: 2),
                Text(sublabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 24),
                onPressed: (!isBlocked && value > 0) ? () => onChanged(value - 1) : null,
                visualDensity: VisualDensity.compact,
              ),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF047857) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$value',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF047857), size: 24),
                onPressed: !isBlocked ? () => onChanged(value + 1) : null,
                visualDensity: VisualDensity.compact,
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
    final isSelected = value > 0;

    if (isBlocked && _autoFilter) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: !isBlocked ? () => onChanged(isSelected ? 0 : 1) : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isBlocked
              ? Colors.red.shade50
              : (isSelected ? const Color(0xFFF0FDF4) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isBlocked
                ? Colors.red.shade200
                : (isSelected ? const Color(0xFF047857) : Colors.grey.shade200),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isBlocked ? Colors.grey.shade700 : (isSelected ? const Color(0xFF065F46) : const Color(0xFF1E293B)),
                          ),
                        ),
                      ),
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
                  const SizedBox(height: 2),
                  Text(sublabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF047857) : Colors.grey.shade400,
              size: 24,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF047857)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetTextField({
    required String label,
    required String sublabel,
    required TextEditingController controller,
    required String suffix,
    required ValueChanged<String> onChanged,
    Color? iconColor,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            CircleAvatar(
              backgroundColor: (iconColor ?? const Color(0xFF047857)).withValues(alpha: 0.1),
              radius: 18,
              child: Icon(icon, color: iconColor ?? const Color(0xFF047857), size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(sublabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                suffixText: suffix,
                suffixStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMale = _heirs.deceasedGender == 'male';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.mosque, color: Color(0xFFF59E0B), size: 22),
            SizedBox(width: 8),
            Text('হানাফি মিরাছ ও ফারায়েজ ক্যালকুলেটর', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF59E0B),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(
              icon: const Icon(Icons.people_alt, size: 18),
              text: '১. ওয়ারিশ নির্বাচন ($_totalHeirsCount জন)',
            ),
            const Tab(
              icon: Icon(Icons.account_balance_wallet, size: 18),
              text: '২. সম্পদ ও দেনা',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_autoFilter ? Icons.filter_alt : Icons.filter_alt_off),
            tooltip: _autoFilter ? 'স্বয়ংক্রিয় হজব ফিল্টার চালু' : 'হজব ফিল্টার বন্ধ',
            onPressed: () {
              setState(() {
                _autoFilter = !_autoFilter;
                if (_autoFilter) {
                  _heirs = HajbRulesService.sanitize(_heirs);
                }
              });
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          return TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: HEIRS SELECTION
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? (constraints.maxWidth - 760) / 2 : 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('মরহুমের লিঙ্গ: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const Spacer(),
                              ChoiceChip(
                                label: const Text('পুরুষ (মৃত)'),
                                selected: isMale,
                                selectedColor: const Color(0xFF047857),
                                labelStyle: TextStyle(color: isMale ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                                onSelected: (v) {
                                  setState(() {
                                    _heirs.deceasedGender = 'male';
                                    _heirs.husband = 0;
                                    if (_autoFilter) _heirs = HajbRulesService.sanitize(_heirs);
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('মহিলা (মৃত)'),
                                selected: !isMale,
                                selectedColor: Colors.purple.shade700,
                                labelStyle: TextStyle(color: !isMale ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                                onSelected: (v) {
                                  setState(() {
                                    _heirs.deceasedGender = 'female';
                                    _heirs.wives = 0;
                                    if (_autoFilter) _heirs = HajbRulesService.sanitize(_heirs);
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.flash_on, size: 16, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              const Text('দ্রুত উদাহরণ (Presets):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const Spacer(),
                              ActionChip(
                                label: const Text('পিতা-মাতা ও সন্তান', style: TextStyle(fontSize: 11)),
                                onPressed: () => _applyPreset('preset1'),
                              ),
                              const SizedBox(width: 4),
                              ActionChip(
                                label: const Text('স্ত্রী ও কন্যা', style: TextStyle(fontSize: 11)),
                                onPressed: () => _applyPreset('preset2'),
                              ),
                              const SizedBox(width: 4),
                              ActionChip(
                                label: const Text('আউল মাসআলা', style: TextStyle(fontSize: 11)),
                                onPressed: () => _applyPreset('preset3'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSectionHeader('১. জীবনসঙ্গী (Spouse)', Icons.favorite),
                    if (isMale)
                      _buildCounterCard('wives', 'স্ত্রী (Wife)', 'সর্বোচ্চ ৪ জন (১/৮ বা ১/৪)', _heirs.wives, (v) => setState(() => _heirs.wives = v))
                    else
                      _buildBinaryCard('husband', 'স্বামী (Husband)', '১/৪ বা ১/২ অংশ', _heirs.husband, (v) => setState(() => _heirs.husband = v)),

                    _buildSectionHeader('২. পিতা-মাতা ও দাদা-দাদি/নানি', Icons.elderly),
                    _buildBinaryCard('father', 'পিতা (Father)', '১/৬ বা আসাবা', _heirs.father, (v) => setState(() => _heirs.father = v)),
                    _buildBinaryCard('mother', 'মাতা (Mother)', '১/৬ বা ১/৩', _heirs.mother, (v) => setState(() => _heirs.mother = v)),
                    _buildBinaryCard('paternalGrandfather', 'দাদা (Grandfather)', 'পিতার অবর্তমানে আসাবা/ফারদ', _heirs.paternalGrandfather, (v) => setState(() => _heirs.paternalGrandfather = v)),
                    _buildBinaryCard('paternalGrandmother', 'দাদি (Pat. Grandmother)', 'পিতা ও মাতার অবর্তমানে ১/৬', _heirs.paternalGrandmother, (v) => setState(() => _heirs.paternalGrandmother = v)),
                    _buildBinaryCard('maternalGrandmother', 'নানি (Mat. Grandmother)', 'মাতার অবর্তমানে ১/৬', _heirs.maternalGrandmother, (v) => setState(() => _heirs.maternalGrandmother = v)),

                    _buildSectionHeader('৩. সন্তান ও পৌত্র-পৌত্রী', Icons.child_care),
                    _buildCounterCard('sons', 'পুত্র (Son)', 'প্রধান আসাবা (কন্যার দ্বিগুণ)', _heirs.sons, (v) => setState(() => _heirs.sons = v)),
                    _buildCounterCard('daughters', 'কন্যা (Daughter)', '১/২, ২/৩ বা আসাবা বিল-গাইর', _heirs.daughters, (v) => setState(() => _heirs.daughters = v)),
                    _buildCounterCard('sonSons', 'পৌত্র (নাতি)', 'পুত্রের অবর্তমানে আসাবা', _heirs.sonSons, (v) => setState(() => _heirs.sonSons = v)),
                    _buildCounterCard('sonDaughters', 'পৌত্রী (নাতনি)', 'পুত্রের অবর্তমানে ফারদ বা আসাবা', _heirs.sonDaughters, (v) => setState(() => _heirs.sonDaughters = v)),

                    _buildSectionHeader('৪. ভাই-বোন (Siblings)', Icons.people),
                    _buildCounterCard('fullBrothers', 'সহোদর ভাই', 'আসাবা (২:১)', _heirs.fullBrothers, (v) => setState(() => _heirs.fullBrothers = v)),
                    _buildCounterCard('fullSisters', 'সহোদর বোন', '১/২, ২/৩ বা আসাবা', _heirs.fullSisters, (v) => setState(() => _heirs.fullSisters = v)),
                    _buildCounterCard('consanguineBrothers', 'বৈমাত্রেয় ভাই', 'পিতা এক, মাতা ভিন্ন (আসাবা)', _heirs.consanguineBrothers, (v) => setState(() => _heirs.consanguineBrothers = v)),
                    _buildCounterCard('consanguineSisters', 'বৈমাত্রেয় বোন', '১/২, ২/৩ বা আসাবা', _heirs.consanguineSisters, (v) => setState(() => _heirs.consanguineSisters = v)),
                    _buildCounterCard('uterineBrothers', 'বৈপিত্রীয় ভাই', 'মাতা এক, পিতা ভিন্ন (১:১ সমবণ্টন)', _heirs.uterineBrothers, (v) => setState(() => _heirs.uterineBrothers = v)),
                    _buildCounterCard('uterineSisters', 'বৈপিত্রীয় বোন', 'মাতা এক, পিতা ভিন্ন (১:১ সমবণ্টন)', _heirs.uterineSisters, (v) => setState(() => _heirs.uterineSisters = v)),

                    _buildSectionHeader('৫. ভাতিজা, চাচা ও চাচাতো ভাই', Icons.group),
                    _buildCounterCard('fullBrotherSons', 'সহোদর ভাতিজা', 'সহোদর ভাইয়ের ছেলে', _heirs.fullBrotherSons, (v) => setState(() => _heirs.fullBrotherSons = v)),
                    _buildCounterCard('consanguineBrotherSons', 'বৈমাত্রেয় ভাতিজা', 'সৎ ভাইয়ের ছেলে', _heirs.consanguineBrotherSons, (v) => setState(() => _heirs.consanguineBrotherSons = v)),
                    _buildCounterCard('fullPaternalUncles', 'সহোদর চাচা', 'পিতার সহোদর ভাই', _heirs.fullPaternalUncles, (v) => setState(() => _heirs.fullPaternalUncles = v)),
                    _buildCounterCard('consanguinePaternalUncles', 'বৈমাত্রেয় চাচা', 'পিতার সৎ ভাই', _heirs.consanguinePaternalUncles, (v) => setState(() => _heirs.consanguinePaternalUncles = v)),
                    _buildCounterCard('fullCousins', 'চাচাতো ভাই (সহোদর)', 'চাচার ছেলে', _heirs.fullCousins, (v) => setState(() => _heirs.fullCousins = v)),
                    _buildCounterCard('consanguineCousins', 'চাচাতো ভাই (বৈমাত্রেয়)', 'সৎ চাচার ছেলে', _heirs.consanguineCousins, (v) => setState(() => _heirs.consanguineCousins = v)),

                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // TAB 2: ASSETS & LIABILITIES INPUTS
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? (constraints.maxWidth - 760) / 2 : 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF047857), Color(0xFF065F46)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF047857).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('মোট নিট বণ্টনযোগ্য সম্পদ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '৳ ${_netDistributableValuation.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const Divider(color: Colors.white24, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('মোট স্থাবর/অস্থাবর', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  Text('৳ ${_grossValuation.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('মোট ঋণ ও ওসিয়ত', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  Text('৳ ${_totalDeductions.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('নিট জমি', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  Text('${_assets.landDecimals} শতক', style: const TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildSectionHeader('কুরআনিক দায় ও অগ্রাধিকার সমূহ (বণ্টনের পূর্বে কর্তন)', Icons.gavel),
                    _buildAssetTextField(
                      label: '১. কাফন-দাফন খরচ',
                      sublabel: 'মরহুমের অন্ত্যেষ্টিক্রিয়ার স্বাভাবিক ব্যয়',
                      controller: _funeralCtrl,
                      suffix: 'টাকা',
                      icon: Icons.person_outline,
                      iconColor: Colors.blueGrey,
                      onChanged: (v) => setState(() => _assets.funeralCost = double.tryParse(v) ?? 0),
                    ),
                    _buildAssetTextField(
                      label: '২. ঋণ ও স্ত্রীর বকেয়া দেনমোহর',
                      sublabel: 'বান্দার হক যা মিরাছের পূর্বে পরিশোধ করা আবশ্যক',
                      controller: _debtsCtrl,
                      suffix: 'টাকা',
                      icon: Icons.money_off,
                      iconColor: Colors.redAccent,
                      onChanged: (v) => setState(() => _assets.debtsAndMahr = double.tryParse(v) ?? 0),
                    ),
                    _buildAssetTextField(
                      label: '৩. ওসিয়ত (Wasiyyah)',
                      sublabel: 'অবশিষ্ট সম্পদের সর্বোচ্চ ১/৩ অংশ পর্যন্ত প্রযোজ্য',
                      controller: _wasiyyahCtrl,
                      suffix: 'টাকা',
                      icon: Icons.history_edu,
                      iconColor: Colors.amber.shade800,
                      onChanged: (v) => setState(() => _assets.wasiyyah = double.tryParse(v) ?? 0),
                    ),

                    const SizedBox(height: 10),

                    _buildSectionHeader('স্থাবর ও অস্থাবর সম্পত্তির বিবরণ', Icons.real_estate_agent),
                    _buildAssetTextField(
                      label: 'নগদ টাকা (Cash)',
                      sublabel: 'ব্যাংক একাউন্ট ও হাতে থাকা মোট নগদ অর্থ',
                      controller: _cashCtrl,
                      suffix: 'টাকা',
                      icon: Icons.attach_money,
                      iconColor: Colors.green,
                      onChanged: (v) => setState(() => _assets.cashMoney = double.tryParse(v) ?? 0),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildAssetTextField(
                            label: 'জমি (Land)',
                            sublabel: 'মোট ভূমির পরিমাণ',
                            controller: _landCtrl,
                            suffix: 'শতাংশ',
                            icon: Icons.landscape,
                            iconColor: Colors.teal,
                            onChanged: (v) => setState(() => _assets.landDecimals = double.tryParse(v) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildAssetTextField(
                            label: 'প্রতি শতকের মূল্য',
                            sublabel: 'বাজারদর আনুমানিক',
                            controller: _landPriceCtrl,
                            suffix: 'টাকা',
                            icon: Icons.price_change,
                            iconColor: Colors.teal.shade700,
                            onChanged: (v) => setState(() => _assets.landPricePerDecimal = double.tryParse(v) ?? 0),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildAssetTextField(
                            label: 'স্বর্ণ (Gold)',
                            sublabel: 'স্বর্ণালঙ্কারের ওজন',
                            controller: _goldCtrl,
                            suffix: 'ভরি',
                            icon: Icons.diamond,
                            iconColor: Colors.amber.shade700,
                            onChanged: (v) => setState(() => _assets.goldBhori = double.tryParse(v) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildAssetTextField(
                            label: 'স্বর্ণের প্রতি ভরি দর',
                            sublabel: 'বর্তমান বাজারদর',
                            controller: _goldPriceCtrl,
                            suffix: 'টাকা',
                            icon: Icons.sell,
                            iconColor: Colors.amber.shade800,
                            onChanged: (v) => setState(() => _assets.goldPricePerBhori = double.tryParse(v) ?? 0),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildAssetTextField(
                            label: 'রৌপ্য (Silver)',
                            sublabel: 'রূপার অলঙ্কারের ওজন',
                            controller: _silverCtrl,
                            suffix: 'ভরি',
                            icon: Icons.blur_circular,
                            iconColor: Colors.blueGrey.shade400,
                            onChanged: (v) => setState(() => _assets.silverBhori = double.tryParse(v) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildAssetTextField(
                            label: 'রৌপ্যের প্রতি ভরি দর',
                            sublabel: 'বর্তমান বাজারদর',
                            controller: _silverPriceCtrl,
                            suffix: 'টাকা',
                            icon: Icons.sell_outlined,
                            iconColor: Colors.blueGrey.shade600,
                            onChanged: (v) => setState(() => _assets.silverPricePerBhori = double.tryParse(v) ?? 0),
                          ),
                        ),
                      ],
                    ),

                    _buildAssetTextField(
                      label: 'অন্যান্য সম্পদ/কোম্পানি শেয়ার',
                      sublabel: 'গাড়ি, ব্যবসা বা অন্যান্য সম্পদের আনুমানিক মূল্য',
                      controller: _otherAssetsCtrl,
                      suffix: 'টাকা',
                      icon: Icons.business_center,
                      iconColor: Colors.indigo,
                      onChanged: (v) => setState(() => _assets.otherAssetsVal = double.tryParse(v) ?? 0),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('নির্বাচিত ওয়ারিশ: $_totalHeirsCount জন', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF047857))),
                    Text('নিট সম্পদ: ৳ ${_netDistributableValuation.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _calculateAndNavigate,
                icon: const Icon(Icons.calculate, size: 20),
                label: const Text('হিসাব সম্পন্ন করুন', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF047857),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}