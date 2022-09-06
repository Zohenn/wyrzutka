import 'package:intl/intl.dart';

class PluralizationRules {
  PluralizationRules({
    required this.one,
    required this.few,
    required this.many,
    required this.other,
  });

  final String one;
  final String few;
  final String many;
  final String other;
}

// one: 1
// few: 2~4, 22~24, 32~34, 42~44, 52~54, 62, 102, 1002, …
// many: 0, 5~19, 100, 1000, 10000, 100000, 1000000, …
// other: 0.0~1.5, 10.0, 100.0, 1000.0, 10000.0, 100000.0, 1000000.0, …

final Map<String, PluralizationRules> _rules = {
  'element': PluralizationRules(
    one: 'element',
    few: 'elementy',
    many: 'elementów',
    other: 'elementu',
  ),
};

String pluralization(String word, num number) {
  final wordRules = _rules[word];
  if (wordRules == null) {
    print('Pluralization data not found for word: $word');
  } else {
    return Intl.plural(
      number,
      one: wordRules.one,
      few: wordRules.few,
      many: wordRules.many,
      other: wordRules.other,
    );
  }

  return word;
}
