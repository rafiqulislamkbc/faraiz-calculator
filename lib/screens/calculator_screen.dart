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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('অনুগ্রহ করে অন্তত একজন ওয়ারিশ নির্বাচন করুন।'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isBlocked
            ? const Color(0xFFFFF1F2)
            : (isSelected ? Colors.white : const Color(0xFFFCFDFD)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isBlocked
              ? const Color(0xFFFECDD3)
              : (isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0)),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF059669).withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Left Indicator Strip
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: isBlocked
                    ? Colors.red.shade400
                    : (isSelected ? const Color(0xFF059669) : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
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
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: isBlocked
                                ? Colors.red.shade900
                                : (isSelected ? const Color(0xFF064E3B) : const Color(0xFF1E293B)),
                          ),
                        ),
                      ),
                      if (isBlocked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'বঞ্চিত ($blockedBy)',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sublabel,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // Modern Stepper Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: (!isBlocked && value > 0) ? () => onChanged(value - 1) : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: value > 0 ? const Color(0xFFFEE2E2) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 18,
                      color: value > 0 ? Colors.red.shade700 : Colors.grey.shade400,
                    ),
                  ),
                ),
                Container(
                  width: 38,
                  alignment: Alignment.center,
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF064E3B) : Colors.grey.shade800,
                    ),
                  ),
                ),
                InkWell(
                  onTap: !isBlocked ? () => onChanged(value + 1) : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 18,
                      color: Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isBlocked
            ? const Color(0xFFFFF1F2)
            : (isSelected ? Colors.white : const Color(0xFFFCFDFD)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isBlocked
              ? const Color(0xFFFECDD3)
              : (isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0)),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF059669).withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )
              ],
      ),
      child: InkWell(
        onTap: !isBlocked ? () => onChanged(isSelected ? 0 : 1) : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(
                  color: isBlocked
                      ? Colors.red.shade400
                      : (isSelected ? const Color(0xFF059669) : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
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
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: isBlocked
                                  ? Colors.red.shade900
                                  : (isSelected ? const Color(0xFF064E3B) : const Color(0xFF1E293B)),
                            ),
                          ),
                        ),
                        if (isBlocked) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'বঞ্চিত ($blockedBy)',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sublabel,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF047857) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF047857) : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: 0.2,
            ),
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
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Text(
                  sublabel,
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 135,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixText: suffix,
                suffixStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF047857), width: 1.8),
                ),
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
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(115),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.mosque, color: Color(0xFFF59E0B), size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'হানাফি মিরাছ ও ফারায়েজ ক্যালকুলেটর',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.5),
                            ),
                            Text(
                              'فَرِيضَةً مِّنَ اللَّهِ • কুরআন ও সুন্নাহ ভিত্তিক বণ্টন',
                              style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _autoFilter ? Icons.filter_alt : Icons.filter_alt_off,
                          color: _autoFilter ? const Color(0xFFFDE68A) : Colors.white60,
                          size: 22,
                        ),
                        tooltip: _autoFilter ? 'হজব ফিল্টার চালু' : 'হজব ফিল্টার বন্ধ',
                        onPressed: () {
                          setState(() {
                            _autoFilter = !_autoFilter;
                            if (_autoFilter) _heirs = HajbRulesService.sanitize(_heirs);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: const Color(0xFF064E3B),
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: [
                      Tab(text: '১. ওয়ারিশ নির্বাচন ($_totalHeirsCount জন)'),
                      const Tab(text: '২. সম্পদ ও দেনা হিসেব'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
                    // Deceased Switcher & Presets
                    Container(
                      padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('মরহুমের তথ্য:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                              const Spacer(),
                              ChoiceChip(
                                label: const Text('👨 পুরুষ (মরহুম)'),
                                selected: isMale,
                                selectedColor: const Color(0xFF047857),
                                labelStyle: TextStyle(color: isMale ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
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
                                label: const Text('👩 নারী (মরহুমা)'),
                                selected: !isMale,
                                selectedColor: Colors.purple.shade700,
                                labelStyle: TextStyle(color: !isMale ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
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
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          Row(
                            children: [
                              const Icon(Icons.bolt, size: 16, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              const Text('দ্রুত মাসআলা:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const Spacer(),
                              ActionChip(
                                label: const Text('পিতা-মাতা ও সন্তান', style: TextStyle(fontSize: 10.5)),
                                onPressed: () => _applyPreset('preset1'),
                              ),
                              const SizedBox(width: 4),
                              ActionChip(
                                label: const Text('স্ত্রী ও কন্যা', style: TextStyle(fontSize: 10.5)),
                                onPressed: () => _applyPreset('preset2'),
                              ),
                              const SizedBox(width: 4),
                              ActionChip(
                                label: const Text('আউল মাসআলা', style: TextStyle(fontSize: 10.5)),
                                onPressed: () => _applyPreset('preset3'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildSectionHeader('১. জীবনসঙ্গী (Spouse)', Icons.favorite, const Color(0xFFE11D48)),
                    if (isMale)
                      _buildCounterCard('wives', 'স্ত্রী (Wife)', 'সর্বোচ্চ ৪ জন (১/৮ বা ১/৪)', _heirs.wives, (v) => setState(() => _heirs.wives = v))
                    else
                      _buildBinaryCard('husband', 'স্বামী (Husband)', '১/৪ বা ১/২ অংশ', _heirs.husband, (v) => setState(() => _heirs.husband = v)),

                    _buildSectionHeader('২. পিতা-মাতা ও দাদা-দাদি/নানি', Icons.elderly, const Color(0xFFD97706)),
                    _buildBinaryCard('father', 'পিতা (Father)', '১/৬ বা আসাবা', _heirs.father, (v) => setState(() => _heirs.father = v)),
                    _buildBinaryCard('mother', 'মাতা (Mother)', '১/৬ বা ১/৩', _heirs.mother, (v) => setState(() => _heirs.mother = v)),
                    _buildBinaryCard('paternalGrandfather', 'দাদা (Grandfather)', 'পিতার অবর্তমানে আসাবা/ফারদ', _heirs.paternalGrandfather, (v) => setState(() => _heirs.paternalGrandfather = v)),
                    _buildBinaryCard('paternalGrandmother', 'দাদি (Pat. Grandmother)', 'পিতা ও মাতার অবর্তমানে ১/৬', _heirs.paternalGrandmother, (v) => setState(() => _heirs.paternalGrandmother = v)),
                    _buildBinaryCard('maternalGrandmother', 'নানি (Mat. Grandmother)', 'মাতার অবর্তমানে ১/৬', _heirs.maternalGrandmother, (v) => setState(() => _heirs.maternalGrandmother = v)),

                    _buildSectionHeader('৩. সন্তান ও পৌত্র-পৌত্রী', Icons.child_care, const Color(0xFF047857)),
                    _buildCounterCard('sons', 'পুত্র (Son)', 'প্রধান আসাবা (কন্যার দ্বিগুণ)', _heirs.sons, (v) => setState(() => _heirs.sons = v)),
                    _buildCounterCard('daughters', 'কন্যা (Daughter)', '১/২, ২/৩ বা আসাবা বিল-গাইর', _heirs.daughters, (v) => setState(() => _heirs.daughters = v)),
                    _buildCounterCard('sonSons', 'পৌত্র (নাতি)', 'পুত্রের অবর্তমানে আসাবা', _heirs.sonSons, (v) => setState(() => _heirs.sonSons = v)),
                    _buildCounterCard('sonDaughters', 'পৌত্রী (নাতনি)', 'পুত্রের অবর্তমানে ফারদ বা আসাবা', _heirs.sonDaughters, (v) => setState(() => _heirs.sonDaughters = v)),

                    _buildSectionHeader('৪. ভাই-বোন (Siblings)', Icons.people, const Color(0xFF4F46E5)),
                    _buildCounterCard('fullBrothers', 'সহোদর ভাই', 'আসাবা (২:১)', _heirs.fullBrothers, (v) => setState(() => _heirs.fullBrothers = v)),
                    _buildCounterCard('fullSisters', 'সহোদর বোন', '১/২, ২/৩ বা আসাবা', _heirs.fullSisters, (v) => setState(() => _heirs.fullSisters = v)),
                    _buildCounterCard('consanguineBrothers', 'বৈমাত্রেয় ভাই', 'পিতা এক, মাতা ভিন্ন (আসাবা)', _heirs.consanguineBrothers, (v) => setState(() => _heirs.consanguineBrothers = v)),
                    _buildCounterCard('consanguineSisters', 'বৈমাত্রেয় বোন', '১/২, ২/৩ বা আসাবা', _heirs.consanguineSisters, (v) => setState(() => _heirs.consanguineSisters = v)),
                    _buildCounterCard('uterineBrothers', 'বৈপিত্রীয় ভাই', 'মাতা এক, পিতা ভিন্ন (১:১ সমবণ্টন)', _heirs.uterineBrothers, (v) => setState(() => _heirs.uterineBrothers = v)),
                    _buildCounterCard('uterineSisters', 'বৈপিত্রীয় বোন', 'মাতা এক, পিতা ভিন্ন (১:১ সমবণ্টন)', _heirs.uterineSisters, (v) => setState(() => _heirs.uterineSisters = v)),

                    _buildSectionHeader('৫. ভাতিজা, চাচা ও চাচাতো ভাই', Icons.group, const Color(0xFF0891B2)),
                    _buildCounterCard('fullBrotherSons', 'সহোদর ভাতিজা', 'সহোদর ভাইয়ের ছেলে', _heirs.fullBrotherSons, (v) => setState(() => _heirs.fullBrotherSons = v)),
                    _buildCounterCard('consanguineBrotherSons', 'বৈমাত্রেয় ভাতিজা', 'সৎ ভাইয়ের ছেলে', _heirs.consanguineBrotherSons, (v) => setState(() => _heirs.consanguineBrotherSons = v)),
                    _buildCounterCard('fullPaternalUncles', 'সহোদর চাচা', 'পিতার সহোদর ভাই', _heirs.fullPaternalUncles, (v) => setState(() => _heirs.fullPaternalUncles = v)),
                    _buildCounterCard('consanguinePaternalUncles', 'বৈমাত্রেয় চাচা', 'পিতার সৎ ভাই', _heirs.consanguinePaternalUncles, (v) => setState(() => _heirs.consanguinePaternalUncles = v)),
                    _buildCounterCard('fullCousins', 'চাচাতো ভাই (সহোদর)', 'চাচার ছেলে', _heirs.fullCousins, (v) => setState(() => _heirs.fullCousins = v)),
                    _buildCounterCard('consanguineCousins', 'চাচাতো ভাই (বৈমাত্রেয়)', 'সৎ চাচার ছেলে', _heirs.consanguineCousins, (v) => setState(() => _heirs.consanguineCousins = v)),

                    const SizedBox(height: 85),
                  ],
                ),
              ),

              // TAB 2: ASSETS & LIABILITIES
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? (constraints.maxWidth - 760) / 2 : 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Royal Hero Net Asset Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF022C22), Color(0xFF064E3B), Color(0xFF047857)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF047857).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stars, color: Color(0xFFFDE68A), size: 18),
                              SizedBox(width: 6),
                              Text('মোট নিট বণ্টনযোগ্য সম্পদ', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '৳ ${_netDistributableValuation.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          const Divider(color: Colors.white24, height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('মোট স্থাবর/অস্থাবর', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  const SizedBox(height: 2),
                                  Text('৳ ${_grossValuation.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              Container(width: 1, height: 25, color: Colors.white24),
                              Column(
                                children: [
                                  const Text('ঋণ ও ওসিয়ত কর্তন', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  const SizedBox(height: 2),
                                  Text('৳ ${_totalDeductions.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              Container(width: 1, height: 25, color: Colors.white24),
                              Column(
                                children: [
                                  const Text('নিট জমি', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  const SizedBox(height: 2),
                                  Text('${_assets.landDecimals} শতক', style: const TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _buildSectionHeader('১. দায় ও কুরআনিক অগ্রাধিকার (বণ্টনের পূর্বে কর্তন)', Icons.gavel, const Color(0xFFDC2626)),
                    _buildAssetTextField(
                      label: 'কাফন-দাফন খরচ',
                      sublabel: 'মরহুমের অন্ত্যেষ্টিক্রিয়ার স্বাভাবিক ব্যয়',
                      controller: _funeralCtrl,
                      suffix: 'টাকা',
                      icon: Icons.person_outline,
                      iconColor: Colors.blueGrey.shade600,
                      onChanged: (v) => setState(() => _assets.funeralCost = double.tryParse(v) ?? 0),
                    ),
                    _buildAssetTextField(
                      label: 'ঋণ ও স্ত্রীর বকেয়া দেনমোহর',
                      sublabel: 'বান্দার হক যা মিরাছের পূর্বে পরিশোধ করা আবশ্যক',
                      controller: _debtsCtrl,
                      suffix: 'টাকা',
                      icon: Icons.money_off,
                      iconColor: Colors.redAccent,
                      onChanged: (v) => setState(() => _assets.debtsAndMahr = double.tryParse(v) ?? 0),
                    ),
                    _buildAssetTextField(
                      label: 'ওসিয়ত (Wasiyyah)',
                      sublabel: 'অবশিষ্ট সম্পদের সর্বোচ্চ ১/৩ অংশ পর্যন্ত প্রযোজ্য',
                      controller: _wasiyyahCtrl,
                      suffix: 'টাকা',
                      icon: Icons.history_edu,
                      iconColor: Colors.amber.shade800,
                      onChanged: (v) => setState(() => _assets.wasiyyah = double.tryParse(v) ?? 0),
                    ),

                    _buildSectionHeader('২. স্থাবর ও অস্থাবর সম্পত্তির বিবরণ', Icons.account_balance, const Color(0xFF047857)),
                    _buildAssetTextField(
                      label: 'নগদ অর্থ (Cash)',
                      sublabel: 'ব্যাংক একাউন্ট ও হাতে থাকা মোট নগদ অর্থ',
                      controller: _cashCtrl,
                      suffix: 'টাকা',
                      icon: Icons.attach_money,
                      iconColor: Colors.green.shade700,
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
                            iconColor: Colors.teal.shade700,
                            onChanged: (v) => setState(() => _assets.landDecimals = double.tryParse(v) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildAssetTextField(
                            label: 'প্রতি শতকের দর',
                            sublabel: 'বাজারদর আনুমানিক',
                            controller: _landPriceCtrl,
                            suffix: 'টাকা',
                            icon: Icons.price_change,
                            iconColor: Colors.teal.shade800,
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildAssetTextField(
                            label: 'স্বর্ণের ভরি দর',
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildAssetTextField(
                            label: 'রৌপ্যের ভরি দর',
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
                      label: 'অন্যান্য সম্পদ/ব্যবসা/শেয়ার',
                      sublabel: 'গাড়ি, কোম্পানি শেয়ার বা অন্যান্য স্থাবর সম্পদ',
                      controller: _otherAssetsCtrl,
                      suffix: 'টাকা',
                      icon: Icons.business_center,
                      iconColor: Colors.indigo.shade600,
                      onChanged: (v) => setState(() => _assets.otherAssetsVal = double.tryParse(v) ?? 0),
                    ),

                    const SizedBox(height: 85),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
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
                    Text(
                      'নির্বাচিত: $_totalHeirsCount জন ওয়ারিশ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF047857)),
                    ),
                    Text(
                      'নিট: ৳ ${_netDistributableValuation.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _calculateAndNavigate,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('হিসাব সম্পন্ন করুন', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF047857),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}