class HeirInput {
  String deceasedGender; // 'male' or 'female'
  int husband;
  int wives;
  int father;
  int mother;
  int paternalGrandfather;
  int paternalGrandmother;
  int maternalGrandmother;
  int sons;
  int daughters;
  int sonSons;
  int sonDaughters;
  int fullBrothers;
  int fullSisters;
  int consanguineBrothers;
  int consanguineSisters;
  int uterineBrothers;
  int uterineSisters;
  int fullBrotherSons;
  int consanguineBrotherSons;
  int fullPaternalUncles;
  int consanguinePaternalUncles;
  int fullCousins;
  int consanguineCousins;

  HeirInput({
    this.deceasedGender = 'male',
    this.husband = 0,
    this.wives = 0,
    this.father = 0,
    this.mother = 0,
    this.paternalGrandfather = 0,
    this.paternalGrandmother = 0,
    this.maternalGrandmother = 0,
    this.sons = 0,
    this.daughters = 0,
    this.sonSons = 0,
    this.sonDaughters = 0,
    this.fullBrothers = 0,
    this.fullSisters = 0,
    this.consanguineBrothers = 0,
    this.consanguineSisters = 0,
    this.uterineBrothers = 0,
    this.uterineSisters = 0,
    this.fullBrotherSons = 0,
    this.consanguineBrotherSons = 0,
    this.fullPaternalUncles = 0,
    this.consanguinePaternalUncles = 0,
    this.fullCousins = 0,
    this.consanguineCousins = 0,
  });

  HeirInput copyWith({
    String? deceasedGender,
    int? husband,
    int? wives,
    int? father,
    int? mother,
    int? paternalGrandfather,
    int? paternalGrandmother,
    int? maternalGrandmother,
    int? sons,
    int? daughters,
    int? sonSons,
    int? sonDaughters,
    int? fullBrothers,
    int? fullSisters,
    int? consanguineBrothers,
    int? consanguineSisters,
    int? uterineBrothers,
    int? uterineSisters,
    int? fullBrotherSons,
    int? consanguineBrotherSons,
    int? fullPaternalUncles,
    int? consanguinePaternalUncles,
    int? fullCousins,
    int? consanguineCousins,
  }) {
    return HeirInput(
      deceasedGender: deceasedGender ?? this.deceasedGender,
      husband: husband ?? this.husband,
      wives: wives ?? this.wives,
      father: father ?? this.father,
      mother: mother ?? this.mother,
      paternalGrandfather: paternalGrandfather ?? this.paternalGrandfather,
      paternalGrandmother: paternalGrandmother ?? this.paternalGrandmother,
      maternalGrandmother: maternalGrandmother ?? this.maternalGrandmother,
      sons: sons ?? this.sons,
      daughters: daughters ?? this.daughters,
      sonSons: sonSons ?? this.sonSons,
      sonDaughters: sonDaughters ?? this.sonDaughters,
      fullBrothers: fullBrothers ?? this.fullBrothers,
      fullSisters: fullSisters ?? this.fullSisters,
      consanguineBrothers: consanguineBrothers ?? this.consanguineBrothers,
      consanguineSisters: consanguineSisters ?? this.consanguineSisters,
      uterineBrothers: uterineBrothers ?? this.uterineBrothers,
      uterineSisters: uterineSisters ?? this.uterineSisters,
      fullBrotherSons: fullBrotherSons ?? this.fullBrotherSons,
      consanguineBrotherSons: consanguineBrotherSons ?? this.consanguineBrotherSons,
      fullPaternalUncles: fullPaternalUncles ?? this.fullPaternalUncles,
      consanguinePaternalUncles: consanguinePaternalUncles ?? this.consanguinePaternalUncles,
      fullCousins: fullCousins ?? this.fullCousins,
      consanguineCousins: consanguineCousins ?? this.consanguineCousins,
    );
  }
}

class AssetInput {
  double cashMoney;
  double landDecimals;
  double landPricePerDecimal;
  double goldBhori;
  double goldPricePerBhori;
  double silverBhori;
  double silverPricePerBhori;
  double otherAssetsVal;
  double funeralCost;
  double debtsAndMahr;
  double wasiyyah;

  AssetInput({
    this.cashMoney = 100000.0,
    this.landDecimals = 10.0,
    this.landPricePerDecimal = 50000.0,
    this.goldBhori = 0.0,
    this.goldPricePerBhori = 120000.0,
    this.silverBhori = 0.0,
    this.silverPricePerBhori = 2000.0,
    this.otherAssetsVal = 0.0,
    this.funeralCost = 0.0,
    this.debtsAndMahr = 0.0,
    this.wasiyyah = 0.0,
  });
}

class HeirShareResult {
  final String heirKey;
  final String nameBn;
  final int count;
  final double fractionNumerator;
  final double fractionDenominator;
  final double percentage;
  final double perPersonPercentage;
  final double cashShare;
  final double landShare;
  final double goldShare;
  final double silverShare;
  final double totalValuationShare;
  final String shareType; // 'fard', 'asaba', 'radd', 'aul'
  final String ruleExplanationBn;
  final String? quranReference;

  HeirShareResult({
    required this.heirKey,
    required this.nameBn,
    required this.count,
    required this.fractionNumerator,
    required this.fractionDenominator,
    required this.percentage,
    required this.perPersonPercentage,
    required this.cashShare,
    required this.landShare,
    required this.goldShare,
    required this.silverShare,
    required this.totalValuationShare,
    required this.shareType,
    required this.ruleExplanationBn,
    this.quranReference,
  });
}

class BlockedHeirInfo {
  final String id;
  final String nameBn;
  final String blockedByBn;
  final String ruleExplanationBn;

  BlockedHeirInfo({
    required this.id,
    required this.nameBn,
    required this.blockedByBn,
    required this.ruleExplanationBn,
  });
}

class MirathCalculationResult {
  final int baseAslMasala;
  final int finalMasala;
  final String status; // 'normal', 'aul', 'radd'
  final String statusExplanationBn;
  final double grossValuation;
  final double totalDeductions;
  final double netDistributableValuation;
  final List<HeirShareResult> heirResults;
  final List<BlockedHeirInfo> blockedHeirs;

  MirathCalculationResult({
    required this.baseAslMasala,
    required this.finalMasala,
    required this.status,
    required this.statusExplanationBn,
    required this.grossValuation,
    required this.totalDeductions,
    required this.netDistributableValuation,
    required this.heirResults,
    required this.blockedHeirs,
  });
}