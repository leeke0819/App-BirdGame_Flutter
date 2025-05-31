class ExperienceLevel {
  static const int MAX_LEVEL = 50; // 최대 레벨 정의

  static Map<int, Map<String, int>> levelRanges = {
    1: {'min': 1, 'max': 10},
    2: {'min': 11, 'max': 25},
    3: {'min': 26, 'max': 50},
    4: {'min': 51, 'max': 90},
    5: {'min': 91, 'max': 140},
    6: {'min': 141, 'max': 200},
    7: {'min': 201, 'max': 270},
    8: {'min': 271, 'max': 350},
    9: {'min': 351, 'max': 440},
    10: {'min': 441, 'max': 540},
    11: {'min': 541, 'max': 650},
    12: {'min': 651, 'max': 770},
    13: {'min': 771, 'max': 900},
    14: {'min': 901, 'max': 1040},
    15: {'min': 1041, 'max': 1190},
    16: {'min': 1191, 'max': 1350},
    17: {'min': 1351, 'max': 1520},
    18: {'min': 1521, 'max': 1700},
    19: {'min': 1701, 'max': 1890},
    20: {'min': 1891, 'max': 2090},
    21: {'min': 2091, 'max': 2300},
    22: {'min': 2301, 'max': 2520},
    23: {'min': 2521, 'max': 2750},
    24: {'min': 2751, 'max': 2990},
    25: {'min': 2991, 'max': 3240},
    26: {'min': 3241, 'max': 3500},
    27: {'min': 3501, 'max': 3770},
    28: {'min': 3771, 'max': 4050},
    29: {'min': 4051, 'max': 4340},
    30: {'min': 4341, 'max': 4640},
    31: {'min': 4641, 'max': 4950},
    32: {'min': 4951, 'max': 5270},
    33: {'min': 5271, 'max': 5600},
    34: {'min': 5601, 'max': 5940},
    35: {'min': 5941, 'max': 6290},
    36: {'min': 6291, 'max': 6650},
    37: {'min': 6651, 'max': 7020},
    38: {'min': 7021, 'max': 7400},
    39: {'min': 7401, 'max': 7790},
    40: {'min': 7791, 'max': 8190},
    41: {'min': 8191, 'max': 8600},
    42: {'min': 8601, 'max': 9020},
    43: {'min': 9021, 'max': 9450},
    44: {'min': 9451, 'max': 9890},
    45: {'min': 9891, 'max': 10340},
    46: {'min': 10341, 'max': 10800},
    47: {'min': 10801, 'max': 11270},
    48: {'min': 11271, 'max': 11750},
    49: {'min': 11751, 'max': 12240},
    50: {'min': 12241, 'max': 12740},
  };

  static double calculateProgress(
      int currentExp, int currentLevel, int maxExp, int minExp) {
    // 최대 레벨 체크
    if (currentLevel > MAX_LEVEL) {
      return 1.0; // 최대 레벨 이상이면 100% 진행률 반환
    }

    if (!levelRanges.containsKey(currentLevel)) {
      return 0.0;
    }

    final range = levelRanges[currentLevel]!;

    // 현재 레벨에서의 경험치 진행률 계산
    final expInCurrentLevel = currentExp - minExp;
    final totalExpForLevel = maxExp - minExp;
    print(expInCurrentLevel);
    print(totalExpForLevel);

    // 0.0과 1.0 사이의 값으로 제한
    return (expInCurrentLevel / totalExpForLevel).clamp(0.0, 1.0);
  }

  static int getMinExpForLevel(int level) {
    return levelRanges[level]?['min'] ?? 1;
  }

  static int getMaxExpForLevel(int level) {
    return levelRanges[level]?['max'] ?? 10;
  }
}
