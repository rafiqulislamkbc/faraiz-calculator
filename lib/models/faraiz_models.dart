enum LawMethod { hanafiClassical, bangladeshLaw1961 }

class HeirInput {
  String deceasedGender; // 'male' or 'female'
  int husband;
  int wives;
  int sons;
  int daughters;
  int father;
  int mother;
  int paternalGrandfather;
  int paternalGrandmother;
  int maternalGrandmother;
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
    this.wives = 1,
    this.sons = 1,
    this.daughters = 2,
    this.father = 1,
    this.mother = 1,
    this.paternalGrandfather = 0,
    this.paternalGrandmother = 0,
    this.maternalGrandmother = 0,
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
    int? sons,
    int? daughters,
    int? father,
    int? mother,
    int? paternalGrandfather,
    int? paternalGrandmother,
    int? maternalGrandmother,
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
      sons: sons ?? this.sons,
      daughters: daughters ?? this.daughters,
      father: father ?? this.father,
      mother: mother ?? this.mother,
      paternalGrandfather: paternalGrandfather ?? this.paternalGrandfather,
      paternalGrandmother: paternalGrandmother ?? this.paternalGrandmother,
      maternalGrandmother: maternalGrandmother ?? this.maternalGrandmother,
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
  double funeralCost;
  double debtsAndMahr;
  double wasiyyah;
  double landDecimals;
  double goldBhori;
  double silverBhori;
  double cashMoney;
  double otherAssetsVal;
  double landPricePerDecimal;
  double goldPricePerBhori;
  double silverPricePerBhori;

  AssetInput({
    this.funeralCost = 25000,
    this.debtsAndMahr = 100000,
    this.wasiyyah = 0,
    this.landDecimals = 50,
    this.goldBhori = 5,
    this.silverBhori = 10,
    this.cashMoney = 500000,
    this.otherAssetsVal = 2000000,
    this.landPricePerDecimal = 120000,
    this.goldPricePerBhori = 135000,
    this.silverPricePerBhori = 2500,
  });
}

class HeirShareResult {
  final String id;
  final String nameBn;
  final String nameAr;
  final int count;
  final String category; // 'zawil_furud' or 'asabah'
  final int ruleId; // 1 to 31 according to Furud rules
  final int asabahClass; // 1 to 4 if Asabah
  final int fractionNumerator;
  final int fractionDenominator;
  final double percentage;
  final double perPersonPercentage;
  final double landShare;
  final double goldShare;
  final double silverShare;
  final double cashShare;
  final double totalValuationShare;
  final String ruleExplanationBn;
  final String? quranReference;

  HeirShareResult({
    required this.id,
    required this.nameBn,
    required this.nameAr,
    required this.count,
    required this.category,
    this.ruleId = 0,
    this.asabahClass = 0,
    required this.fractionNumerator,
    required this.fractionDenominator,
    required this.percentage,
    required this.perPersonPercentage,
    required this.landShare,
    required this.goldShare,
    required this.silverShare,
    required this.cashShare,
    required this.totalValuationShare,
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

class FaraizCalculationOutput {
  final LawMethod lawMethod;
  final int aslAlMasala;
  final int finalMasala;
  final String distributionType; // 'normal', 'awl', 'radd', 'umariyyatan'
  final String distributionSummaryBn;
  final double funeralDeducted;
  final double debtDeducted;
  final double wasiyyahDeducted;
  final double netLandDecimals;
  final double netGoldBhori;
  final double netSilverBhori;
  final double netCashMoney;
  final double totalGrossValuation;
  final double netDistributableValuation;
  final List<HeirShareResult> shares;
  final List<BlockedHeirInfo> blockedHeirs;

  FaraizCalculationOutput({
    required this.lawMethod,
    required this.aslAlMasala,
    required this.finalMasala,
    required this.distributionType,
    required this.distributionSummaryBn,
    required this.funeralDeducted,
    required this.debtDeducted,
    required this.wasiyyahDeducted,
    required this.netLandDecimals,
    required this.netGoldBhori,
    required this.netSilverBhori,
    required this.netCashMoney,
    required this.totalGrossValuation,
    required this.netDistributableValuation,
    required this.shares,
    required this.blockedHeirs,
  });
}