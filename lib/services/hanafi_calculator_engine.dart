import '../models/faraiz_models.dart';
import 'hajb_rules_service.dart';

class HanafiCalculatorEngine {
  static MirathCalculationResult calculate({
    required HeirInput heirs,
    required AssetInput assets,
  }) {
    // 1. Assets Valuation Math
    final grossLandVal = assets.landDecimals * assets.landPricePerDecimal;
    final grossGoldVal = assets.goldBhori * assets.goldPricePerBhori;
    final grossSilverVal = assets.silverBhori * assets.silverPricePerBhori;
    final grossValuation = grossLandVal + grossGoldVal + grossSilverVal + assets.cashMoney + assets.otherAssetsVal;

    final afterFuneral = grossValuation > assets.funeralCost ? grossValuation - assets.funeralCost : 0.0;
    final debtDeducted = assets.debtsAndMahr > afterFuneral ? afterFuneral : assets.debtsAndMahr;
    final afterDebt = afterFuneral > debtDeducted ? afterFuneral - debtDeducted : 0.0;
    final maxWasiyyah = afterDebt / 3.0;
    final wasiyyahDeducted = assets.wasiyyah > maxWasiyyah ? maxWasiyyah : assets.wasiyyah;
    final totalDeductions = assets.funeralCost + debtDeducted + wasiyyahDeducted;

    final netDistributableValuation = grossValuation > totalDeductions ? grossValuation - totalDeductions : 0.0;
    final netCash = assets.cashMoney;
    final netLand = assets.landDecimals;
    final netGold = assets.goldBhori;
    final netSilver = assets.silverBhori;

    // 2. Shares and Asaba Logic
    List<HeirShareResult> results = [];
    List<BlockedHeirInfo> blocked = [];

    final nameMapBn = {
      'husband': 'স্বামী',
      'wives': 'স্ত্রী',
      'father': 'পিতা',
      'mother': 'মাতা',
      'paternalGrandfather': 'দাদা',
      'paternalGrandmother': 'দাদি',
      'maternalGrandmother': 'নানি',
      'sons': 'পুত্র',
      'daughters': 'কন্যা',
      'sonSons': 'পৌত্র (নাতি)',
      'sonDaughters': 'পৌত্রী (নাতনি)',
      'fullBrothers': 'সহোদর ভাই',
      'fullSisters': 'সহোদর বোন',
      'consanguineBrothers': 'বৈমাত্রেয় ভাই',
      'consanguineSisters': 'বৈমাত্রেয় বোন',
      'uterineBrothers': 'বৈপিত্রীয় ভাই',
      'uterineSisters': 'বৈপিত্রীয় বোন',
      'fullBrotherSons': 'সহোদর ভাতিজা',
      'consanguineBrotherSons': 'বৈমাত্রেয় ভাতিজা',
      'fullPaternalUncles': 'সহোদর চাচা',
      'consanguinePaternalUncles': 'বৈমাত্রেয় চাচা',
      'fullCousins': 'চাচাতো ভাই (সহোদর)',
      'consanguineCousins': 'চাচাতো ভাই (বৈমাত্রেয়)',
    };

    final hajbMap = HajbRulesService.evaluate(heirs);
    hajbMap.forEach((key, val) {
      if (val.isExcluded) {
        blocked.add(BlockedHeirInfo(
          id: key,
          nameBn: nameMapBn[key] ?? key,
          blockedByBn: val.blockedByBn ?? '',
          ruleExplanationBn: val.reasonBn ?? '',
        ));
      }
    });

    final sanitizedHeirs = HajbRulesService.sanitize(heirs);
    final hasChildren = sanitizedHeirs.sons > 0 || sanitizedHeirs.daughters > 0 || sanitizedHeirs.sonSons > 0 || sanitizedHeirs.sonDaughters > 0;
    final totalSiblings = sanitizedHeirs.fullBrothers + sanitizedHeirs.fullSisters + sanitizedHeirs.consanguineBrothers + sanitizedHeirs.consanguineSisters + sanitizedHeirs.uterineBrothers + sanitizedHeirs.uterineSisters;

    Map<String, double> rawFardShares = {};
    Map<String, String> fardExplanations = {};
    Map<String, String> fardQurans = {};

    if (sanitizedHeirs.deceasedGender == 'female' && sanitizedHeirs.husband > 0) {
      rawFardShares['husband'] = hasChildren ? 0.25 : 0.50;
      fardExplanations['husband'] = hasChildren ? 'সন্তান থাকায় স্বামী ১/৪ অংশ পাবেন।' : 'কোনো সন্তান না থাকায় স্বামী ১/২ অংশ পাবেন।';
      fardQurans['husband'] = 'সূরা আন-নিসা: ১২';
    }

    if (sanitizedHeirs.deceasedGender == 'male' && sanitizedHeirs.wives > 0) {
      rawFardShares['wives'] = hasChildren ? 0.125 : 0.25;
      fardExplanations['wives'] = hasChildren ? 'সন্তান থাকায় স্ত্রীগণ একত্রে ১/৮ অংশ পাবেন।' : 'কোনো সন্তান না থাকায় স্ত্রীগণ একত্রে ১/৪ অংশ পাবেন।';
      fardQurans['wives'] = 'সূরা আন-নিসা: ১২';
    }

    if (sanitizedHeirs.mother > 0) {
      final motherShare = (hasChildren || totalSiblings >= 2) ? (1.0 / 6.0) : (1.0 / 3.0);
      rawFardShares['mother'] = motherShare;
      fardExplanations['mother'] = (hasChildren || totalSiblings >= 2)
          ? 'সন্তান বা একাধিক ভাই-বোন থাকায় মাতা ১/৬ অংশ পাবেন।'
          : 'সন্তান ও একাধিক ভাই-বোন না থাকায় মাতা ১/৩ অংশ পাবেন।';
      fardQurans['mother'] = 'সূরা আন-নিসা: ১১';
    }

    if (sanitizedHeirs.father > 0) {
      if (sanitizedHeirs.sons > 0 || sanitizedHeirs.sonSons > 0) {
        rawFardShares['father'] = 1.0 / 6.0;
        fardExplanations['father'] = 'পুত্র বা নাতি থাকায় পিতা নির্ধারিত ১/৬ অংশ পাবেন।';
        fardQurans['father'] = 'সূরা আন-নিসা: ১১';
      } else if (sanitizedHeirs.daughters > 0 || sanitizedHeirs.sonDaughters > 0) {
        rawFardShares['father'] = 1.0 / 6.0;
        fardExplanations['father'] = 'কন্যা/নাতনি থাকায় পিতা ১/৬ এবং অবশিষ্ট আসাবা হিসেবে পাবেন।';
        fardQurans['father'] = 'সূরা আন-নিসা: ১১';
      }
    }

    if (sanitizedHeirs.sons == 0 && sanitizedHeirs.daughters > 0) {
      rawFardShares['daughters'] = sanitizedHeirs.daughters == 1 ? 0.50 : (2.0 / 3.0);
      fardExplanations['daughters'] = sanitizedHeirs.daughters == 1 ? 'একমাত্র কন্যা হওয়ায় নির্ধারিত ১/২ অংশ পাবেন।' : 'একাধিক কন্যা হওয়ায় একত্রে ২/৩ অংশ সমবণ্টন পাবেন।';
      fardQurans['daughters'] = 'সূরা আন-নিসা: ১১';
    }

    if (sanitizedHeirs.sons == 0 && sanitizedHeirs.daughters == 0 && sanitizedHeirs.sonSons == 0 && sanitizedHeirs.sonDaughters > 0) {
      rawFardShares['sonDaughters'] = sanitizedHeirs.sonDaughters == 1 ? 0.50 : (2.0 / 3.0);
      fardExplanations['sonDaughters'] = 'পুত্রের অবর্তমানে পৌত্রী ফারদ অংশী পাবেন।';
      fardQurans['sonDaughters'] = 'সূরা আন-নিসা: ১১';
    }

    if (!hasChildren && sanitizedHeirs.father == 0 && sanitizedHeirs.fullBrothers == 0 && sanitizedHeirs.fullSisters > 0) {
      rawFardShares['fullSisters'] = sanitizedHeirs.fullSisters == 1 ? 0.50 : (2.0 / 3.0);
      fardExplanations['fullSisters'] = sanitizedHeirs.fullSisters == 1 ? 'সন্তান ও পিতা না থাকায় একমাত্র সহোদর বোন ১/২ পাবেন।' : 'একাধিক সহোদর বোন ২/৩ অংশ পাবেন।';
      fardQurans['fullSisters'] = 'সূরা আন-নিসা: ১৭৬';
    }

    final totalUterine = sanitizedHeirs.uterineBrothers + sanitizedHeirs.uterineSisters;
    if (!hasChildren && sanitizedHeirs.father == 0 && sanitizedHeirs.paternalGrandfather == 0 && totalUterine > 0) {
      final uShare = totalUterine == 1 ? (1.0 / 6.0) : (1.0 / 3.0);
      if (sanitizedHeirs.uterineBrothers > 0) {
        rawFardShares['uterineBrothers'] = uShare * (sanitizedHeirs.uterineBrothers / totalUterine);
        fardExplanations['uterineBrothers'] = 'বৈপিত্রীয় ভাই-বোন একত্রে সমবণ্টন (১:১) নীতিতে পাবেন।';
        fardQurans['uterineBrothers'] = 'সূরা আন-নিসা: ১২';
      }
      if (sanitizedHeirs.uterineSisters > 0) {
        rawFardShares['uterineSisters'] = uShare * (sanitizedHeirs.uterineSisters / totalUterine);
        fardExplanations['uterineSisters'] = 'বৈপিত্রীয় ভাই-বোন একত্রে সমবণ্টন (১:১) নীতিতে পাবেন।';
        fardQurans['uterineSisters'] = 'সূরা আন-নিসা: ১২';
      }
    }

    double sumFard = rawFardShares.values.fold(0.0, (a, b) => a + b);
    String status = 'normal';
    String statusExplanationBn = 'কুরআন ও সুন্নাহর নির্ধারিত অংশ অনুযায়ী বণ্টন সম্পন্ন হয়েছে।';
    Map<String, double> finalPercentages = {};

    if (sumFard > 1.00001) {
      status = 'aul';
      statusExplanationBn = 'জাবিল ফুরুজের মোট অংশ ১ এর বেশি হওয়ায় আউল (العول) নীতিতে সকল অংশীদারের প্রাপ্য আনুপাতিক হারে সমন্বয় করা হয়েছে।';
      rawFardShares.forEach((k, v) {
        finalPercentages[k] = (v / sumFard) * 100.0;
      });
    } else {
      double remainder = 1.0 - sumFard;
      Map<String, double> asabaDistribution = {};

      if (sanitizedHeirs.sons > 0) {
        final totalUnits = (sanitizedHeirs.sons * 2) + sanitizedHeirs.daughters;
        if (totalUnits > 0) {
          if (sanitizedHeirs.daughters > 0) {
            rawFardShares.remove('daughters');
            remainder = 1.0 - rawFardShares.values.fold(0.0, (a, b) => a + b);
          }
          final unitVal = remainder / totalUnits;
          asabaDistribution['sons'] = unitVal * (sanitizedHeirs.sons * 2);
          if (sanitizedHeirs.daughters > 0) {
            asabaDistribution['daughters'] = unitVal * sanitizedHeirs.daughters;
          }
        }
      } else if (sanitizedHeirs.father > 0 && remainder > 0.0001) {
        asabaDistribution['father'] = (asabaDistribution['father'] ?? 0.0) + remainder;
      } else if (sanitizedHeirs.fullBrothers > 0) {
        final units = (sanitizedHeirs.fullBrothers * 2) + sanitizedHeirs.fullSisters;
        if (units > 0) {
          rawFardShares.remove('fullSisters');
          remainder = 1.0 - rawFardShares.values.fold(0.0, (a, b) => a + b);
          final unitVal = remainder / units;
          asabaDistribution['fullBrothers'] = unitVal * (sanitizedHeirs.fullBrothers * 2);
          if (sanitizedHeirs.fullSisters > 0) {
            asabaDistribution['fullSisters'] = unitVal * sanitizedHeirs.fullSisters;
          }
        }
      }

      rawFardShares.forEach((k, v) {
        finalPercentages[k] = (v * 100.0);
      });

      asabaDistribution.forEach((k, v) {
        finalPercentages[k] = (finalPercentages[k] ?? 0.0) + (v * 100.0);
      });

      double totalDistributed = finalPercentages.values.fold(0.0, (a, b) => a + b);
      if (totalDistributed < 99.99 && asabaDistribution.isEmpty) {
        status = 'radd';
        statusExplanationBn = 'অবশিষ্ট কোনো আসাবা না থাকায় রদ্দ (الرد) নীতিতে স্বামী/স্ত্রী ব্যতীত অন্যান্য জাবিল ফুরুজদের মধ্যে অতিরিক্ত অংশ আনুপাতিক হারে ফিরিয়ে দেওয়া হয়েছে।';
        final nonSpouseTotal = finalPercentages.entries.where((e) => e.key != 'husband' && e.key != 'wives').fold(0.0, (a, b) => a + b.value);
        if (nonSpouseTotal > 0) {
          final spousePercentage = (finalPercentages['husband'] ?? 0.0) + (finalPercentages['wives'] ?? 0.0);
          final availableForRadd = 100.0 - spousePercentage;
          finalPercentages.keys.toList().forEach((k) {
            if (k != 'husband' && k != 'wives') {
              final currentP = finalPercentages[k]!;
              finalPercentages[k] = (currentP / nonSpouseTotal) * availableForRadd;
            }
          });
        }
      }
    }

    finalPercentages.forEach((key, percentage) {
      if (percentage > 0.001) {
        int count = 1;
        if (key == 'wives') count = sanitizedHeirs.wives;
        if (key == 'sons') count = sanitizedHeirs.sons;
        if (key == 'daughters') count = sanitizedHeirs.daughters;
        if (key == 'sonSons') count = sanitizedHeirs.sonSons;
        if (key == 'sonDaughters') count = sanitizedHeirs.sonDaughters;
        if (key == 'fullBrothers') count = sanitizedHeirs.fullBrothers;
        if (key == 'fullSisters') count = sanitizedHeirs.fullSisters;
        if (key == 'consanguineBrothers') count = sanitizedHeirs.consanguineBrothers;
        if (key == 'consanguineSisters') count = sanitizedHeirs.consanguineSisters;
        if (key == 'uterineBrothers') count = sanitizedHeirs.uterineBrothers;
        if (key == 'uterineSisters') count = sanitizedHeirs.uterineSisters;

        final ratio = percentage / 100.0;
        final totalVal = netDistributableValuation * ratio;
        final cash = netCash * ratio;
        final land = netLand * ratio;
        final gold = netGold * ratio;
        final silver = netSilver * ratio;

        results.add(HeirShareResult(
          heirKey: key,
          nameBn: nameMapBn[key] ?? key,
          count: count > 0 ? count : 1,
          fractionNumerator: percentage,
          fractionDenominator: 100.0,
          percentage: percentage,
          perPersonPercentage: percentage / (count > 0 ? count : 1),
          cashShare: cash,
          landShare: land,
          goldShare: gold,
          silverShare: silver,
          totalValuationShare: totalVal,
          shareType: status,
          ruleExplanationBn: fardExplanations[key] ?? 'আসাবা বা সমন্বিত অংশের ভিত্তিতে প্রাপ্যতা নির্ধারিত হয়েছে।',
          quranReference: fardQurans[key],
        ));
      }
    });

    return MirathCalculationResult(
      baseAslMasala: 24,
      finalMasala: 24,
      status: status,
      statusExplanationBn: statusExplanationBn,
      grossValuation: grossValuation,
      totalDeductions: totalDeductions,
      netDistributableValuation: netDistributableValuation,
      heirResults: results,
      blockedHeirs: blocked,
    );
  }
}