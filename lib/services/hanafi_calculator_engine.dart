import '../models/faraiz_models.dart';
import 'hajb_rules_service.dart';

class RawFraction {
  final int num;
  final int den;
  const RawFraction(this.num, this.den);
  double toDouble() => num / den;
}

class HanafiCalculatorEngine {
  static FaraizCalculationOutput calculate({
    required HeirInput heirs,
    required AssetInput assets,
    LawMethod lawMethod = LawMethod.hanafiClassical,
  }) {
    // Sanitize heirs through Hajb rules first
    final sanitizedHeirs = HajbRulesService.sanitize(heirs);

    // Asset Gross & Deductions
    double landVal = assets.landDecimals * assets.landPricePerDecimal;
    double goldVal = assets.goldBhori * assets.goldPricePerBhori;
    double silverVal = assets.silverBhori * assets.silverPricePerBhori;
    double grossVal = landVal + goldVal + silverVal + assets.cashMoney + assets.otherAssetsVal;

    double funeralDeducted = assets.funeralCost;
    double afterFuneral = grossVal > funeralDeducted ? grossVal - funeralDeducted : 0.0;

    double debtDeducted = assets.debtsAndMahr > afterFuneral ? afterFuneral : assets.debtsAndMahr;
    double afterDebt = afterFuneral > debtDeducted ? afterFuneral - debtDeducted : 0.0;

    double maxWasiyyahAllowed = afterDebt / 3.0;
    double wasiyyahDeducted = assets.wasiyyah > maxWasiyyahAllowed ? maxWasiyyahAllowed : assets.wasiyyah;
    double netValuation = afterDebt > wasiyyahDeducted ? afterDebt - wasiyyahDeducted : 0.0;

    double deductionRatio = grossVal > 0 ? netValuation / grossVal : 1.0;
    double netLand = assets.landDecimals * deductionRatio;
    double netGold = assets.goldBhori * deductionRatio;
    double netSilver = assets.silverBhori * deductionRatio;
    double netCash = assets.cashMoney * deductionRatio;

    List<HeirShareResult> results = [];
    List<BlockedHeirInfo> blocked = [];

    // Evaluate blocked heirs for reporting
    final hajbMap = HajbRulesService.evaluate(heirs);
    hajbMap.forEach((key, val) {
      if (val.isExcluded && key != 'husband' && key != 'wives') {
        blocked.add(BlockedHeirInfo(
          id: key,
          nameBn: key,
          blockedByBn: val.blockedByBn,
          ruleExplanationBn: val.reasonBn,
        ));
      }
    });

    final bool hasSon = sanitizedHeirs.sons > 0;
    final bool hasSonSon = sanitizedHeirs.sonSons > 0;
    final bool hasDaughter = sanitizedHeirs.daughters > 0;
    final bool hasSonDaughter = sanitizedHeirs.sonDaughters > 0;
    final bool hasChildrenOrGrandchildren = hasSon || hasDaughter || hasSonSon || hasSonDaughter;
    final bool hasMaleDescendant = hasSon || hasSonSon;

    int totalSiblings = sanitizedHeirs.fullBrothers +
        sanitizedHeirs.fullSisters +
        sanitizedHeirs.consanguineBrothers +
        sanitizedHeirs.consanguineSisters +
        sanitizedHeirs.uterineBrothers +
        sanitizedHeirs.uterineSisters;

    // ==========================================
    // STEP 1: ZAWIL FURUD ASSIGNMENT (31 RULES)
    // ==========================================
    Map<String, RawFraction> furudFractions = {};
    Map<String, int> furudRuleIds = {};
    Map<String, String> furudExplanations = {};

    // 1 & 2: Husband
    if (sanitizedHeirs.deceasedGender == 'female' && sanitizedHeirs.husband > 0) {
      if (hasChildrenOrGrandchildren) {
        furudFractions['husband'] = const RawFraction(1, 4);
        furudRuleIds['husband'] = 1;
        furudExplanations['husband'] = 'বিধি (১): সন্তান বা পুত্রের সন্তান থাকায় স্বামী ১/৪ অংশ পাবেন।';
      } else {
        furudFractions['husband'] = const RawFraction(1, 2);
        furudRuleIds['husband'] = 2;
        furudExplanations['husband'] = 'বিধি (২): কোনো সন্তান বা নাতি-নাতনি না থাকায় স্বামী ১/২ অংশ পাবেন।';
      }
    }

    // 3 & 4: Wives
    if (sanitizedHeirs.deceasedGender == 'male' && sanitizedHeirs.wives > 0) {
      if (hasChildrenOrGrandchildren) {
        furudFractions['wives'] = const RawFraction(1, 8);
        furudRuleIds['wives'] = 3;
        furudExplanations['wives'] = 'বিধি (৩): সন্তান বা পৌত্র থাকায় স্ত্রী ১/৮ অংশ (একাধিক হলে সমবণ্টন) পাবেন।';
      } else {
        furudFractions['wives'] = const RawFraction(1, 4);
        furudRuleIds['wives'] = 4;
        furudExplanations['wives'] = 'বিধি (৪): সন্তান বা নাতি-নাতনি না থাকায় স্ত্রী ১/৪ অংশ পাবেন।';
      }
    }

    // 5, 6, 7: Daughters (Only if no Son)
    if (sanitizedHeirs.daughters > 0 && !hasSon) {
      if (sanitizedHeirs.daughters == 1) {
        furudFractions['daughters'] = const RawFraction(1, 2);
        furudRuleIds['daughters'] = 5;
        furudExplanations['daughters'] = 'বিধি (৫): একমাত্র কন্যা এবং পুত্র না থাকায় ১/২ অংশ পাবেন।';
      } else {
        furudFractions['daughters'] = const RawFraction(2, 3);
        furudRuleIds['daughters'] = 6;
        furudExplanations['daughters'] = 'বিধি (৬): দুই বা ততোধিক কন্যা এবং পুত্র না থাকায় ২/৩ অংশ সমবণ্টন পাবেন।';
      }
    }

    // 8, 9: Son's Daughters (পৌত্রী) (Only if no Son, Son's Son, or multiple daughters)
    if (sanitizedHeirs.sonDaughters > 0 && !hasSon && !hasSonSon) {
      if (sanitizedHeirs.daughters == 0) {
        if (sanitizedHeirs.sonDaughters == 1) {
          furudFractions['sonDaughters'] = const RawFraction(1, 2);
          furudRuleIds['sonDaughters'] = 8;
          furudExplanations['sonDaughters'] = 'বিধি (৮): পুত্রের অবর্তমানে একমাত্র পৌত্রী ১/২ অংশ পাবেন।';
        } else {
          furudFractions['sonDaughters'] = const RawFraction(2, 3);
          furudRuleIds['sonDaughters'] = 9;
          furudExplanations['sonDaughters'] = 'বিধি (৯): দুই বা ততোধিক পৌত্রী ২/৩ অংশ সমবণ্টন পাবেন।';
        }
      } else if (sanitizedHeirs.daughters == 1) {
        furudFractions['sonDaughters'] = const RawFraction(1, 6);
        furudRuleIds['sonDaughters'] = 26; // তাকমিলাতুস সুলুসাইন
        furudExplanations['sonDaughters'] = 'বিধি (২৬/১০): একমাত্র কন্যার সাথে মহিলাদের ২/৩ পূর্ণ করতে পৌত্রী ১/৬ অংশ পাবেন।';
      }
    }

    // 11, 12, 13: Father (ফারদ ১/৬ if male descendant)
    if (sanitizedHeirs.father > 0) {
      if (hasMaleDescendant) {
        furudFractions['father'] = const RawFraction(1, 6);
        furudRuleIds['father'] = 11;
        furudExplanations['father'] = 'বিধি (১১): পুত্র বা পৌত্র থাকায় পিতা নির্ধারিত ১/৬ অংশ পাবেন।';
      } else if (hasDaughter || hasSonDaughter) {
        furudFractions['father'] = const RawFraction(1, 6);
        furudRuleIds['father'] = 12;
        furudExplanations['father'] = 'বিধি (১২): কন্যা উপস্থিত থাকায় পিতা ১/৬ ফারদ + আসাবা হিসেবে অবশিষ্টাংশ পাবেন।';
      }
    }

    // 14, 15, 16: Mother
    if (sanitizedHeirs.mother > 0) {
      bool spousePresent = sanitizedHeirs.husband > 0 || sanitizedHeirs.wives > 0;
      bool onlySpouseAndParents = spousePresent && sanitizedHeirs.father > 0 && !hasChildrenOrGrandchildren && totalSiblings < 2;

      if (hasChildrenOrGrandchildren || totalSiblings >= 2) {
        furudFractions['mother'] = const RawFraction(1, 6);
        furudRuleIds['mother'] = 14;
        furudExplanations['mother'] = 'বিধি (১৪): সন্তান বা ২+ ভাই-বোন থাকায় মাতা ১/৬ অংশ পাবেন।';
      } else if (onlySpouseAndParents) {
        furudRuleIds['mother'] = 16;
        furudExplanations['mother'] = 'বিধি (১৬): উমারিয়াতান মাসয়ালা (স্বামী/স্ত্রীর অংশের পর অবশিষ্টের ১/৩ অংশ)।';
        // Will be adjusted during calculation
        furudFractions['mother'] = sanitizedHeirs.husband > 0 ? const RawFraction(1, 6) : const RawFraction(1, 4);
      } else {
        furudFractions['mother'] = const RawFraction(1, 3);
        furudRuleIds['mother'] = 15;
        furudExplanations['mother'] = 'বিধি (১৫): সন্তান ও একাধিক ভাই-বোন না থাকায় মাতা ১/৩ অংশ পাবেন।';
      }
    }

    // 17, 18, 19: Paternal Grandfather
    if (sanitizedHeirs.paternalGrandfather > 0 && sanitizedHeirs.father == 0) {
      if (hasMaleDescendant) {
        furudFractions['paternalGrandfather'] = const RawFraction(1, 6);
        furudRuleIds['paternalGrandfather'] = 17;
        furudExplanations['paternalGrandfather'] = 'বিধি (১৭): পিতার অবর্তমানে পুত্র/পৌত্র থাকায় দাদা ১/৬ অংশ পাবেন।';
      } else if (hasDaughter || hasSonDaughter) {
        furudFractions['paternalGrandfather'] = const RawFraction(1, 6);
        furudRuleIds['paternalGrandfather'] = 18;
        furudExplanations['paternalGrandfather'] = 'বিধি (১৮): পিতার অবর্তমানে কন্যা থাকায় দাদা ১/৬ ফারদ + আসাবা পাবেন।';
      }
    }

    // 20: Grandmothers (দাদি ও নানি)
    if (sanitizedHeirs.mother == 0) {
      if (sanitizedHeirs.paternalGrandmother > 0 && sanitizedHeirs.maternalGrandmother > 0 && sanitizedHeirs.father == 0) {
        furudFractions['paternalGrandmother'] = const RawFraction(1, 12);
        furudFractions['maternalGrandmother'] = const RawFraction(1, 12);
        furudRuleIds['paternalGrandmother'] = 20;
        furudRuleIds['maternalGrandmother'] = 20;
        furudExplanations['paternalGrandmother'] = 'বিধি (২০): মাতা ও পিতা না থাকায় দাদি ও নানি ১/৬ অংশ সমবণ্টন (১/১২) পাবেন।';
        furudExplanations['maternalGrandmother'] = 'বিধি (২০): মাতা না থাকায় নানি ১/৬ এর অর্ধেক (১/১২) অংশ পাবেন।';
      } else if (sanitizedHeirs.maternalGrandmother > 0) {
        furudFractions['maternalGrandmother'] = const RawFraction(1, 6);
        furudRuleIds['maternalGrandmother'] = 20;
        furudExplanations['maternalGrandmother'] = 'বিধি (২০): মাতা না থাকায় নানি ১/৬ অংশ পাবেন।';
      } else if (sanitizedHeirs.paternalGrandmother > 0 && sanitizedHeirs.father == 0) {
        furudFractions['paternalGrandmother'] = const RawFraction(1, 6);
        furudRuleIds['paternalGrandmother'] = 20;
        furudExplanations['paternalGrandmother'] = 'বিধি (২০): পিতা ও মাতা না থাকায় দাদি ১/৬ অংশ পাবেন।';
      }
    }

    // 21, 22, 23: Full Sisters (Only if no Male Branch, Father, Grandfather, or Full Brother)
    if (sanitizedHeirs.fullSisters > 0 && !hasMaleDescendant && sanitizedHeirs.father == 0 && sanitizedHeirs.paternalGrandfather == 0 && sanitizedHeirs.fullBrothers == 0 && !hasDaughter && !hasSonDaughter) {
      if (sanitizedHeirs.fullSisters == 1) {
        furudFractions['fullSisters'] = const RawFraction(1, 2);
        furudRuleIds['fullSisters'] = 21;
        furudExplanations['fullSisters'] = 'বিধি (২১): সন্তান, পিতা ও ভাই না থাকায় একমাত্র সহোদর বোন ১/২ অংশ পাবেন।';
      } else {
        furudFractions['fullSisters'] = const RawFraction(2, 3);
        furudRuleIds['fullSisters'] = 22;
        furudExplanations['fullSisters'] = 'বিধি (২২): সন্তান ও পিতা না থাকায় একাধিক সহোদর বোন ২/৩ অংশ সমবণ্টন পাবেন।';
      }
    }

    // 24, 25, 26: Consanguine Sisters (বৈমাত্রেয় বোন)
    if (sanitizedHeirs.consanguineSisters > 0 && !hasMaleDescendant && sanitizedHeirs.father == 0 && sanitizedHeirs.paternalGrandfather == 0 && sanitizedHeirs.fullBrothers == 0 && sanitizedHeirs.consanguineBrothers == 0 && !hasDaughter && !hasSonDaughter) {
      if (sanitizedHeirs.fullSisters == 0) {
        if (sanitizedHeirs.consanguineSisters == 1) {
          furudFractions['consanguineSisters'] = const RawFraction(1, 2);
          furudRuleIds['consanguineSisters'] = 24;
          furudExplanations['consanguineSisters'] = 'বিধি (২৪): পূর্ণ ভাই-বোন ও পিতা না থাকায় একমাত্র বৈমাত্রেয় বোন ১/২ অংশ পাবেন।';
        } else {
          furudFractions['consanguineSisters'] = const RawFraction(2, 3);
          furudRuleIds['consanguineSisters'] = 25;
          furudExplanations['consanguineSisters'] = 'বিধি (২৫): দুই বা ততোধিক বৈমাত্রেয় বোন ২/৩ অংশ সমবণ্টন পাবেন।';
        }
      } else if (sanitizedHeirs.fullSisters == 1) {
        furudFractions['consanguineSisters'] = const RawFraction(1, 6);
        furudRuleIds['consanguineSisters'] = 26;
        furudExplanations['consanguineSisters'] = 'বিধি (২৬): এক সহোদর বোনের সাথে ২/৩ পূর্ণ করতে বৈমাত্রেয় বোন ১/৬ অংশ পাবেন।';
      }
    }

    // 28, 29, 30, 31: Uterine Siblings (বৈপিত্রীয় ভাই ও বোন - ১:১ সমান নীতি)
    int totalUterine = sanitizedHeirs.uterineBrothers + sanitizedHeirs.uterineSisters;
    if (totalUterine > 0 && !hasChildrenOrGrandchildren && sanitizedHeirs.father == 0 && sanitizedHeirs.paternalGrandfather == 0) {
      if (totalUterine == 1) {
        if (sanitizedHeirs.uterineBrothers == 1) {
          furudFractions['uterineBrothers'] = const RawFraction(1, 6);
          furudRuleIds['uterineBrothers'] = 28;
          furudExplanations['uterineBrothers'] = 'বিধি (২৮): সন্তান ও পিতা না থাকায় একমাত্র বৈপিত্রীয় ভাই ১/৬ অংশ পাবেন।';
        } else {
          furudFractions['uterineSisters'] = const RawFraction(1, 6);
          furudRuleIds['uterineSisters'] = 30;
          furudExplanations['uterineSisters'] = 'বিধি (৩০): সন্তান ও পিতা না থাকায় একমাত্র বৈপিত্রীয় বোন ১/৬ অংশ পাবেন।';
        }
      } else {
        if (sanitizedHeirs.uterineBrothers > 0) {
          furudFractions['uterineBrothers'] = RawFraction(sanitizedHeirs.uterineBrothers, 3 * totalUterine);
          furudRuleIds['uterineBrothers'] = 29;
          furudExplanations['uterineBrothers'] = 'বিধি (২৯): একাধিক বৈপিত্রীয় ভাই-বোন ১/৩ অংশ সমবণ্টন (১:১) পাবেন।';
        }
        if (sanitizedHeirs.uterineSisters > 0) {
          furudFractions['uterineSisters'] = RawFraction(sanitizedHeirs.uterineSisters, 3 * totalUterine);
          furudRuleIds['uterineSisters'] = 31;
          furudExplanations['uterineSisters'] = 'বিধি (৩১): একাধিক বৈপিত্রীয় ভাই-বোন ১/৩ অংশ সমবণ্টন (১:১) পাবেন।';
        }
      }
    }

    // Calculate sum of Zawil Furud
    double furudSum = 0.0;
    furudFractions.forEach((_, f) => furudSum += f.toDouble());

    // =========================================================================
    // STEP 2 & 3: AWL (আউল) AND RADD (রদ্দ) ADJUSTMENT
    // =========================================================================
    String distributionType = 'normal';
    String distributionSummaryBn = 'হানাফি ফিকহের মূলনীতি অনুযায়ী নিখুঁত বণ্টন সম্পন্ন হয়েছে।';

    Map<String, double> finalPercentages = {};

    // Check if Asabah is present
    bool asabahPresent = hasSon ||
        (hasDaughter && hasSon) ||
        (!hasMaleDescendant && sanitizedHeirs.father > 0) ||
        (!hasMaleDescendant && sanitizedHeirs.father == 0 && sanitizedHeirs.paternalGrandfather > 0) ||
        (sanitizedHeirs.fullBrothers > 0) ||
        (sanitizedHeirs.fullSisters > 0 && (hasDaughter || hasSonDaughter || sanitizedHeirs.fullBrothers > 0)) ||
        (sanitizedHeirs.consanguineBrothers > 0) ||
        (sanitizedHeirs.fullBrotherSons > 0) ||
        (sanitizedHeirs.fullPaternalUncles > 0) ||
        (sanitizedHeirs.fullCousins > 0);

    if (furudSum > 1.0) {
      // STEP 2: AWL (العول) - Proportional Reduction
      distributionType = 'awl';
      distributionSummaryBn = 'ধাপ (২) - আউল (العول): জবিউল ফুরুজের অংশের সমষ্টি ১-এর বেশি হওয়ায় সকল অংশীদারদের অংশ আনুপাতিক হারে সমন্বয় করা হয়েছে।';
      furudFractions.forEach((k, f) {
        finalPercentages[k] = (f.toDouble() / furudSum) * 100.0;
      });
    } else if (furudSum < 1.0 && !asabahPresent) {
      // STEP 3: RADD (الرد) - Return surplus to blood Zawil Furud (excluding Spouse)
      distributionType = 'radd';
      distributionSummaryBn = 'ধাপ (৩) - রদ্দ (الرد): কোনো আসাবা না থাকায় জীবনসঙ্গীর নির্দিষ্ট অংশ বজায় রেখে অবশিষ্ট সম্পদ রক্তীয় জবিউল ফুরুজদের মধ্যে বর্ধিত করা হয়েছে।';
      
      double spouseShare = (furudFractions['husband']?.toDouble() ?? 0.0) + (furudFractions['wives']?.toDouble() ?? 0.0);
      double nonSpouseSum = furudSum - spouseShare;

      furudFractions.forEach((k, f) {
        if (k == 'husband' || k == 'wives') {
          finalPercentages[k] = f.toDouble() * 100.0;
        } else {
          double availableForBlood = 1.0 - spouseShare;
          double scaledShare = nonSpouseSum > 0 ? (f.toDouble() / nonSpouseSum) * availableForBlood : f.toDouble();
          finalPercentages[k] = scaledShare * 100.0;
        }
      });
    } else {
      // Normal Allocation
      furudFractions.forEach((k, f) {
        finalPercentages[k] = f.toDouble() * 100.0;
      });
    }

    // =========================================================================
    // STEP 4: ASABAH (অবশিষ্টভোগী) - 4 CLASSES IN STRICT PRIORITY
    // =========================================================================
    double currentAllocated = finalPercentages.values.fold(0.0, (sum, v) => sum + v);
    double remainingForAsabah = 100.0 - currentAllocated;
    if (remainingForAsabah < 0.0001) remainingForAsabah = 0.0;

    if (remainingForAsabah > 0) {
      // CLASS 1: সন্তান ও পৌত্র (Sons & Daughters 2:1, or Son's Sons)
      if (sanitizedHeirs.sons > 0) {
        int units = (sanitizedHeirs.sons * 2) + sanitizedHeirs.daughters;
        double unitVal = remainingForAsabah / units;

        finalPercentages['sons'] = unitVal * (sanitizedHeirs.sons * 2);
        furudRuleIds['sons'] = 7;
        furudExplanations['sons'] = 'আসাবা শ্রেণী (১): পুত্র অবশিষ্ট সম্পত্তির প্রধান আসাবা (কন্যার দ্বিগুণ অনুপাতে ২:১)।';

        if (sanitizedHeirs.daughters > 0) {
          finalPercentages['daughters'] = unitVal * sanitizedHeirs.daughters;
          furudRuleIds['daughters'] = 7;
          furudExplanations['daughters'] = 'আসাবা শ্রেণী (১): পুত্রের উপস্থিতিতে কন্যা আসাবা বিল-গাইর হয়ে ২:১ অনুপাতে পাবেন।';
        }
      } else if (sanitizedHeirs.sonSons > 0) {
        int units = (sanitizedHeirs.sonSons * 2) + sanitizedHeirs.sonDaughters;
        double unitVal = remainingForAsabah / units;
        finalPercentages['sonSons'] = unitVal * (sanitizedHeirs.sonSons * 2);
        furudRuleIds['sonSons'] = 10;
        furudExplanations['sonSons'] = 'আসাবা শ্রেণী (১): পুত্রের অবর্তমানে পৌত্র আসাবা হিসেবে অবশিষ্টাংশ পাবেন।';

        if (sanitizedHeirs.sonDaughters > 0) {
          finalPercentages['sonDaughters'] = unitVal * sanitizedHeirs.sonDaughters;
          furudRuleIds['sonDaughters'] = 10;
          furudExplanations['sonDaughters'] = 'আসাবা শ্রেণী (১): পৌত্রের সাথে পৌত্রী ২:১ অনুপাতে আসাবা বিল-গাইর হবেন।';
        }
      }
      // CLASS 2: পিতা ও দাদা (Father / Grandfather)
      else if (sanitizedHeirs.father > 0) {
        finalPercentages['father'] = (finalPercentages['father'] ?? 0.0) + remainingForAsabah;
        furudRuleIds['father'] = hasChildrenOrGrandchildren ? 12 : 13;
        furudExplanations['father'] = hasChildrenOrGrandchildren
            ? 'আসাবা শ্রেণী (২): পিতা ১/৬ ফারদ গ্রহণের পর অবশিষ্ট অংশ আসাবা হিসেবে লাভ করবেন।'
            : 'আসাবা শ্রেণী (২): সন্তানাদি না থাকায় পিতা সম্পূর্ণ অবশিষ্টাংশের আসাবা হবেন।';
      } else if (sanitizedHeirs.paternalGrandfather > 0) {
        finalPercentages['paternalGrandfather'] = (finalPercentages['paternalGrandfather'] ?? 0.0) + remainingForAsabah;
        furudRuleIds['paternalGrandfather'] = 19;
        furudExplanations['paternalGrandfather'] = 'আসাবা শ্রেণী (২): পিতার অনুপস্থিতিতে দাদা অবশিষ্ট সম্পত্তির আসাবা হবেন।';
      }
      // CLASS 3: ভাই-বোন ও ভাতিজা
      else if (sanitizedHeirs.fullBrothers > 0) {
        int units = (sanitizedHeirs.fullBrothers * 2) + sanitizedHeirs.fullSisters;
        double unitVal = remainingForAsabah / units;
        finalPercentages['fullBrothers'] = unitVal * (sanitizedHeirs.fullBrothers * 2);
        furudRuleIds['fullBrothers'] = 23;
        furudExplanations['fullBrothers'] = 'আসাবা শ্রেণী (৩): সহোদর ভাই আসাবা হিসেবে অবশিষ্ট সম্পত্তি পাবেন (২:১)।';

        if (sanitizedHeirs.fullSisters > 0) {
          finalPercentages['fullSisters'] = unitVal * sanitizedHeirs.fullSisters;
          furudRuleIds['fullSisters'] = 23;
          furudExplanations['fullSisters'] = 'আসাবা শ্রেণী (৩): সহোদর ভাইয়ের সাথে বোন আসাবা বিল-গাইর হবেন (২:১)।';
        }
      } else if (sanitizedHeirs.fullSisters > 0 && (hasDaughter || hasSonDaughter)) {
        finalPercentages['fullSisters'] = remainingForAsabah;
        furudRuleIds['fullSisters'] = 23;
        furudExplanations['fullSisters'] = 'আসাবা শ্রেণী (৩): কন্যার সাথে সহোদর বোন আসাবা মাআল গাইর হিসেবে অবশিষ্ট লাভ করবেন।';
      } else if (sanitizedHeirs.consanguineBrothers > 0) {
        int units = (sanitizedHeirs.consanguineBrothers * 2) + sanitizedHeirs.consanguineSisters;
        double unitVal = remainingForAsabah / units;
        finalPercentages['consanguineBrothers'] = unitVal * (sanitizedHeirs.consanguineBrothers * 2);
        furudRuleIds['consanguineBrothers'] = 27;
        furudExplanations['consanguineBrothers'] = 'আসাবা শ্রেণী (৩): বৈমাত্রেয় ভাই আসাবা হিসেবে অবশিষ্টাংশ পাবেন।';

        if (sanitizedHeirs.consanguineSisters > 0) {
          finalPercentages['consanguineSisters'] = unitVal * sanitizedHeirs.consanguineSisters;
          furudRuleIds['consanguineSisters'] = 27;
          furudExplanations['consanguineSisters'] = 'আসাবা শ্রেণী (৩): বৈমাত্রেয় ভাইয়ের সাথে বোন আসাবা বিল-গাইর হবেন।';
        }
      } else if (sanitizedHeirs.fullBrotherSons > 0) {
        finalPercentages['fullBrotherSons'] = remainingForAsabah;
        furudExplanations['fullBrotherSons'] = 'আসাবা শ্রেণী (৩): সহোদর ভাতিজা অবশিষ্ট সম্পত্তির আসাবা হবেন।';
      } else if (sanitizedHeirs.consanguineBrotherSons > 0) {
        finalPercentages['consanguineBrotherSons'] = remainingForAsabah;
        furudExplanations['consanguineBrotherSons'] = 'আসাবা শ্রেণী (৩): বৈমাত্রেয় ভাতিজা অবশিষ্ট সম্পত্তির আসাবা হবেন।';
      }
      // CLASS 4: চাচা ও চাচাতো ভাই
      else if (sanitizedHeirs.fullPaternalUncles > 0) {
        finalPercentages['fullPaternalUncles'] = remainingForAsabah;
        furudExplanations['fullPaternalUncles'] = 'আসাবা শ্রেণী (৪): সহোদর চাচা অবশিষ্ট সম্পত্তির আসাবা হবেন।';
      } else if (sanitizedHeirs.consanguinePaternalUncles > 0) {
        finalPercentages['consanguinePaternalUncles'] = remainingForAsabah;
        furudExplanations['consanguinePaternalUncles'] = 'আসাবা শ্রেণী (৪): বৈমাত্রেয় চাচা অবশিষ্ট সম্পত্তির আসাবা হবেন।';
      } else if (sanitizedHeirs.fullCousins > 0) {
        finalPercentages['fullCousins'] = remainingForAsabah;
        furudExplanations['fullCousins'] = 'আসাবা শ্রেণী (৪): সহোদর চাচাতো ভাই অবশিষ্ট সম্পত্তির আসাবা হবেন।';
      } else if (sanitizedHeirs.consanguineCousins > 0) {
        finalPercentages['consanguineCousins'] = remainingForAsabah;
        furudExplanations['consanguineCousins'] = 'আসাবা শ্রেণী (৪): বৈমাত্রেয় চাচাতো ভাই অবশিষ্ট সম্পত্তির আসাবা হবেন।';
      }
    }

    // Build Final Output List
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

    final countMap = {
      'husband': sanitizedHeirs.husband,
      'wives': sanitizedHeirs.wives,
      'father': sanitizedHeirs.father,
      'mother': sanitizedHeirs.mother,
      'paternalGrandfather': sanitizedHeirs.paternalGrandfather,
      'paternalGrandmother': sanitizedHeirs.paternalGrandmother,
      'maternalGrandmother': sanitizedHeirs.maternalGrandmother,
      'sons': sanitizedHeirs.sons,
      'daughters': sanitizedHeirs.daughters,
      'sonSons': sanitizedHeirs.sonSons,
      'sonDaughters': sanitizedHeirs.sonDaughters,
      'fullBrothers': sanitizedHeirs.fullBrothers,
      'fullSisters': sanitizedHeirs.fullSisters,
      'consanguineBrothers': sanitizedHeirs.consanguineBrothers,
      'consanguineSisters': sanitizedHeirs.consanguineSisters,
      'uterineBrothers': sanitizedHeirs.uterineBrothers,
      'uterineSisters': sanitizedHeirs.uterineSisters,
      'fullBrotherSons': sanitizedHeirs.fullBrotherSons,
      'consanguineBrotherSons': sanitizedHeirs.consanguineBrotherSons,
      'fullPaternalUncles': sanitizedHeirs.fullPaternalUncles,
      'consanguinePaternalUncles': sanitizedHeirs.consanguinePaternalUncles,
      'fullCousins': sanitizedHeirs.fullCousins,
      'consanguineCousins': sanitizedHeirs.consanguineCousins,
    };

    finalPercentages.forEach((key, pct) {
      if (pct > 0.0001) {
        int count = countMap[key] ?? 1;
        if (count < 1) count = 1;
        double decimalFraction = pct / 100.0;

        results.add(HeirShareResult(
          id: key,
          nameBn: nameMapBn[key] ?? key,
          nameAr: '',
          count: count,
          category: furudFractions.containsKey(key) ? 'zawil_furud' : 'asabah',
          ruleId: furudRuleIds[key] ?? 0,
          fractionNumerator: (decimalFraction * 1000).round(),
          fractionDenominator: 1000,
          percentage: pct,
          perPersonPercentage: pct / count,
          landShare: netLand * decimalFraction,
          goldShare: netGold * decimalFraction,
          silverShare: netSilver * decimalFraction,
          cashShare: netCash * decimalFraction,
          totalValuationShare: netValuation * decimalFraction,
          ruleExplanationBn: furudExplanations[key] ?? 'হানাফি ফিকহ অনুযায়ী নির্ধারিত অংশ লাভ করেছেন।',
          quranReference: 'সূরা আন-নিসা: ১১, ১২, ১৭৬',
        ));
      }
    });

    return FaraizCalculationOutput(
      lawMethod: lawMethod,
      aslAlMasala: 24,
      finalMasala: 24,
      distributionType: distributionType,
      distributionSummaryBn: distributionSummaryBn,
      funeralDeducted: funeralDeducted,
      debtDeducted: debtDeducted,
      wasiyyahDeducted: wasiyyahDeducted,
      netLandDecimals: netLand,
      netGoldBhori: netGold,
      netSilverBhori: netSilver,
      netCashMoney: netCash,
      totalGrossValuation: grossVal,
      netDistributableValuation: netValuation,
      shares: results,
      blockedHeirs: blocked,
    );
  }
}
