import 'package:inzynierka/models/product/sort_element.dart';

enum ProductSortFilters {
  verified,
  unverified,
  noProposals;

  static String get groupKey => 'sort';

  static String get groupName => 'Segregacja';

  String get filterName {
    switch (this) {
      case ProductSortFilters.verified:
        return 'Zweryfikowano';
      case ProductSortFilters.unverified:
        return 'Niezweryfikowano';
      case ProductSortFilters.noProposals:
        return 'Brak propozycji';
    }
  }
}

enum ProductContainerFilters {
  plastic,
  paper,
  bio,
  mixed,
  glass,
  many;

  static String get groupKey => 'containers';

  static String get groupName => 'Pojemniki';

  String get filterName {
    switch (this) {
      case ProductContainerFilters.plastic:
        return ElementContainer.plastic.containerName;
      case ProductContainerFilters.paper:
        return ElementContainer.paper.containerName;
      case ProductContainerFilters.bio:
        return ElementContainer.bio.containerName;
      case ProductContainerFilters.mixed:
        return ElementContainer.mixed.containerName;
      case ProductContainerFilters.glass:
        return ElementContainer.glass.containerName;
      case ProductContainerFilters.many:
        return 'Wiele pojemników';
    }
  }
}