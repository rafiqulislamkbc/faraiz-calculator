import '../models/faraiz_models.dart';

class ExclusionInfo {
  final bool isExcluded;
  final String blockedByBn;
  final String reasonBn;

  const ExclusionInfo({
    required this.isExcluded,
    this.blockedByBn = '',
    this.reasonBn = '',
  });
}

class HajbRulesService {
  static Map<String, ExclusionInfo> evaluate(HeirInput heirs) {
    final bool isMale = heirs.deceasedGender == 'male';
    final bool hasSon = heirs.sons > 0;
    final bool hasSonSon = heirs.sonSons > 0;
    final bool hasDaughter = heirs.daughters > 0;
    final bool hasSonDaughter = heirs.sonDaughters > 0;

    final bool hasMaleBranch = hasSon || hasSonSon;
    final bool hasAnyChildOrGrandchild = hasSon || hasDaughter || hasSonSon || hasSonDaughter;

    final bool hasFather = heirs.father > 0;
    final bool hasMother = heirs.mother > 0;
    final bool hasPaternalGrandfather = heirs.paternalGrandfather > 0;

    final bool hasFullBrother = heirs.fullBrothers > 0;
    final bool hasFullSister = heirs.fullSisters > 0;
    final bool hasConsanguineBrother = heirs.consanguineBrothers > 0;
    final bool hasConsanguineSister = heirs.consanguineSisters > 0;

    final bool isFullSisterAsabahWithDaughter =
        hasFullSister && (hasDaughter || hasSonDaughter) && !hasFullBrother && !hasMaleBranch;
    final bool isConsanguineSisterAsabahWithDaughter = hasConsanguineSister &&
        (hasDaughter || hasSonDaughter) &&
        !hasConsanguineBrother &&
        !hasMaleBranch &&
        !hasFullBrother &&
        !hasFullSister;

    final bool hasFullBrotherSon = heirs.fullBrotherSons > 0;
    final bool hasConsanguineBrotherSon = heirs.consanguineBrotherSons > 0;
    final bool hasFullPaternalUncle = heirs.fullPaternalUncles > 0;
    final bool hasConsanguinePaternalUncle = heirs.consanguinePaternalUncles > 0;
    final bool hasFullCousin = heirs.fullCousins > 0;

    const notBlocked = ExclusionInfo(isExcluded: false);

    return {
      'husband': isMale
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'পুরুষ (স্বামী)',
              reasonBn: 'মৃত ব্যক্তি পুরুষ হওয়ায় স্বামী অপশন প্রযোজ্য নয়।')
          : notBlocked,
      'wives': !isMale
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'মহিলা (স্ত্রী)',
              reasonBn: 'মৃত ব্যক্তি মহিলা হওয়ায় স্ত্রী অপশন প্রযোজ্য নয়।')
          : notBlocked,
      'father': notBlocked,
      'mother': notBlocked,
      'paternalGrandfather': hasFather
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'পিতা',
              reasonBn: 'পিতা জীবিত থাকায় দাদা সম্পূর্ণ বঞ্চিত হন।')
          : notBlocked,
      'paternalGrandmother': hasMother
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'মাতা',
              reasonBn: 'মাতা জীবিত থাকায় দাদি বঞ্চিত হন।')
          : hasFather
              ? const ExclusionInfo(
                  isExcluded: true,
                  blockedByBn: 'পিতা',
                  reasonBn: 'পিতা জীবিত থাকায় দাদি বঞ্চিত হন।')
              : notBlocked,
      'maternalGrandmother': hasMother
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'মাতা',
              reasonBn: 'মাতা জীবিত থাকায় নানি সম্পূর্ণ বঞ্চিত হন।')
          : notBlocked,
      'sons': notBlocked,
      'daughters': notBlocked,
      'sonSons': hasSon
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'পুত্র',
              reasonBn: 'পুত্র জীবিত থাকায় পৌত্র সম্পূর্ণ বঞ্চিত হন।')
          : notBlocked,
      'sonDaughters': hasSon
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'পুত্র',
              reasonBn: 'পুত্র জীবিত থাকায় পৌত্রী সম্পূর্ণ বঞ্চিত হন।')
          : notBlocked,
      'fullBrothers': hasSon
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'পুত্র',
              reasonBn: 'পুত্র জীবিত থাকায় সহোদর ভাই বঞ্চিত হন।')
          : hasSonSon
              ? const ExclusionInfo(
                  isExcluded: true,
                  blockedByBn: 'পৌত্র',
                  reasonBn: 'পৌত্র জীবিত থাকায় সহোদর ভাই বঞ্চিত হন।')
              : hasFather
                  ? const ExclusionInfo(
                      isExcluded: true,
                      blockedByBn: 'পিতা',
                      reasonBn: 'পিতা জীবিত থাকায় সহোদর ভাই বঞ্চিত হন।')
                  : hasPaternalGrandfather
                      ? const ExclusionInfo(
                          isExcluded: true,
                          blockedByBn: 'দাদা',
                          reasonBn: 'হানাফি মতে দাদা থাকলে ভাই বঞ্চিত হন।')
                      : notBlocked,
      'fullSisters': hasSon
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'পুত্র',
              reasonBn: 'পুত্র জীবিত থাকায় সহোদর বোন বঞ্চিত হন।')
          : hasSonSon
              ? const ExclusionInfo(
                  isExcluded: true,
                  blockedByBn: 'পৌত্র',
                  reasonBn: 'পৌত্র জীবিত থাকায় সহোদর বোন বঞ্চিত হন।')
              : hasFather
                  ? const ExclusionInfo(
                      isExcluded: true,
                      blockedByBn: 'পিতা',
                      reasonBn: 'পিতা জীবিত থাকায় সহোদর বোন বঞ্চিত হন।')
                  : hasPaternalGrandfather
                      ? const ExclusionInfo(
                          isExcluded: true,
                          blockedByBn: 'দাদা',
                          reasonBn: 'হানাফি মতে দাদা থাকলে বোন বঞ্চিত হন।')
                      : notBlocked,
      'consanguineBrothers': hasSon || hasSonSon || hasFather || hasPaternalGrandfather || hasFullBrother || isFullSisterAsabahWithDaughter
          ? ExclusionInfo(
              isExcluded: true,
              blockedByBn: hasSon ? 'পুত্র' : hasFather ? 'পিতা' : 'সহোদর ভাই/আসাবা',
              reasonBn: 'নিকটবর্তী আসাবা জীবিত থাকায় বৈমাত্রেয় ভাই বঞ্চিত হন।')
          : notBlocked,
      'consanguineSisters': hasSon || hasSonSon || hasFather || hasPaternalGrandfather || hasFullBrother || isFullSisterAsabahWithDaughter
          ? ExclusionInfo(
              isExcluded: true,
              blockedByBn: hasSon ? 'পুত্র' : hasFather ? 'পিতা' : 'সহোদর ভাই/আসাবা',
              reasonBn: 'নিকটবর্তী আসাবা জীবিত থাকায় বৈমাত্রেয় বোন বঞ্চিত হন।')
          : notBlocked,
      'uterineBrothers': hasAnyChildOrGrandchild || hasFather || hasPaternalGrandfather
          ? ExclusionInfo(
              isExcluded: true,
              blockedByBn: hasAnyChildOrGrandchild ? 'সন্তান/নাতি' : 'পিতা/দাদা',
              reasonBn: 'সন্তান বা পিতা/দাদা থাকলে বৈপিত্রীয় ভাই সম্পূর্ণ বঞ্চিত হন।')
          : notBlocked,
      'uterineSisters': hasAnyChildOrGrandchild || hasFather || hasPaternalGrandfather
          ? ExclusionInfo(
              isExcluded: true,
              blockedByBn: hasAnyChildOrGrandchild ? 'সন্তান/নাতি' : 'পিতা/দাদা',
              reasonBn: 'সন্তান বা পিতা/দাদা থাকলে বৈপিত্রীয় বোন সম্পূর্ণ বঞ্চিত হন।')
          : notBlocked,
      'fullBrotherSons': hasSon || hasSonSon || hasFather || hasPaternalGrandfather || hasFullBrother || hasConsanguineBrother || isFullSisterAsabahWithDaughter
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'নিকটবর্তী আসাবা',
              reasonBn: 'নিকটবর্তী পুরুষ আসাবা থাকায় ভাতিজা বঞ্চিত হন।')
          : notBlocked,
      'consanguineBrotherSons': hasSon || hasSonSon || hasFather || hasPaternalGrandfather || hasFullBrother || hasConsanguineBrother || hasFullBrotherSon || isFullSisterAsabahWithDaughter || isConsanguineSisterAsabahWithDaughter
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'সহোদর ভাতিজা/আসাবা',
              reasonBn: 'নিকটবর্তী আসাবা থাকায় বৈমাত্রেয় ভাতিজা বঞ্চিত হন।')
          : notBlocked,
      'fullPaternalUncles': hasSon || hasSonSon || hasFather || hasPaternalGrandfather || hasFullBrother || hasConsanguineBrother || hasFullBrotherSon || hasConsanguineBrotherSon || isFullSisterAsabahWithDaughter || isConsanguineSisterAsabahWithDaughter
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'নিকটবর্তী আসাবা',
              reasonBn: 'নিকটবর্তী আসাবা থাকায় সহোদর চাচা বঞ্চিত হন।')
          : notBlocked,
      'consanguinePaternalUncles': hasSon || hasSonSon || hasFather || hasPaternalGrandfather || hasFullBrother || hasConsanguineBrother || hasFullBrotherSon || hasConsanguineBrotherSon || hasFullPaternalUncle || isFullSisterAsabahWithDaughter || isConsanguineSisterAsabahWithDaughter
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'সহোদর চাচা',
              reasonBn: 'সহোদর চাচা থাকায় বৈমাত্রেয় চাচা বঞ্চিত হন।')
          : notBlocked,
      'fullCousins': hasSon || hasSonSon || hasFather || hasPaternalGrandfather || hasFullBrother || hasConsanguineBrother || hasFullBrotherSon || hasConsanguineBrotherSon || hasFullPaternalUncle || hasConsanguinePaternalUncle || isFullSisterAsabahWithDaughter || isConsanguineSisterAsabahWithDaughter
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'চাচা/নিকটবর্তী আসাবা',
              reasonBn: 'চাচা জীবিত থাকায় চাচাতো ভাই বঞ্চিত হন।')
          : notBlocked,
      'consanguineCousins': hasSon || hasSonSon || hasFather || hasPaternalGrandfather || hasFullBrother || hasConsanguineBrother || hasFullBrotherSon || hasConsanguineBrotherSon || hasFullPaternalUncle || hasConsanguinePaternalUncle || hasFullCousin || isFullSisterAsabahWithDaughter || isConsanguineSisterAsabahWithDaughter
          ? const ExclusionInfo(
              isExcluded: true,
              blockedByBn: 'সহোদর চাচাতো ভাই',
              reasonBn: 'সহোদর চাচাতো ভাই থাকায় বৈমাত্রেয় চাচাতো ভাই বঞ্চিত হন।')
          : notBlocked,
    };
  }

  static HeirInput sanitize(HeirInput input) {
    final map = evaluate(input);
    final copy = input.copyWith();

    if (input.deceasedGender == 'male') {
      copy.husband = 0;
    } else {
      copy.wives = 0;
    }

    if (map['paternalGrandfather']?.isExcluded ?? false) copy.paternalGrandfather = 0;
    if (map['paternalGrandmother']?.isExcluded ?? false) copy.paternalGrandmother = 0;
    if (map['maternalGrandmother']?.isExcluded ?? false) copy.maternalGrandmother = 0;
    if (map['sonSons']?.isExcluded ?? false) copy.sonSons = 0;
    if (map['sonDaughters']?.isExcluded ?? false) copy.sonDaughters = 0;
    if (map['fullBrothers']?.isExcluded ?? false) copy.fullBrothers = 0;
    if (map['fullSisters']?.isExcluded ?? false) copy.fullSisters = 0;
    if (map['consanguineBrothers']?.isExcluded ?? false) copy.consanguineBrothers = 0;
    if (map['consanguineSisters']?.isExcluded ?? false) copy.consanguineSisters = 0;
    if (map['uterineBrothers']?.isExcluded ?? false) copy.uterineBrothers = 0;
    if (map['uterineSisters']?.isExcluded ?? false) copy.uterineSisters = 0;
    if (map['fullBrotherSons']?.isExcluded ?? false) copy.fullBrotherSons = 0;
    if (map['consanguineBrotherSons']?.isExcluded ?? false) copy.consanguineBrotherSons = 0;
    if (map['fullPaternalUncles']?.isExcluded ?? false) copy.fullPaternalUncles = 0;
    if (map['consanguinePaternalUncles']?.isExcluded ?? false) copy.consanguinePaternalUncles = 0;
    if (map['fullCousins']?.isExcluded ?? false) copy.fullCousins = 0;
    if (map['consanguineCousins']?.isExcluded ?? false) copy.consanguineCousins = 0;

    return copy;
  }
}
