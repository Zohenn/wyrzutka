// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:collection/collection.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';
import 'package:inzynierka/models/product/vote.dart';

List<AppUser> users = [
  const AppUser(id: '1', email: '1', name: 'Wojtek', surname: 'Brandeburg'),
  const AppUser(id: '2', email: '2', name: 'Michał', surname: 'Marciniak'),
];

AppUser? getUser(String? email) {
  if (email != null) return users.firstWhereOrNull((element) => element.email == email);
  return null;
}

final symbols = [
  const ProductSymbol(
    id: 'budlC2aRgOumb2c0RsQL',
    name: 'Tektura',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/symbols%2Fpap.png?alt=media&token=17495d20-605a-4c1c-acc6-ad6df3f548e8',
    description: 'Opakowanie wykonane z tektury',
  ),
  const ProductSymbol(
    id: '6EudWBDUR1T8zgoqoYVl',
    name: 'Dbaj o czystość',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/symbols%2Fclean.png?alt=media&token=6b0d3093-4545-458e-9842-75491c53e4fa',
    description: 'Opakowanie wyrzuć do kosza',
  ),
];

ProductSymbol? getSymbol(String name) {
  return symbols.firstWhereOrNull((element) => element.id == name);
}

Product? getProductById(String id) {
  return productsList.firstWhereOrNull((element) => element.id == id);
}

final productsList = [
  Product(
    id: '354789',
    name: 'Woda niegazowana',
    photoSmall: 'woda',
    symbols: ['budlC2aRgOumb2c0RsQL'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: 'xxx',
    user: '1',
    addedDate: DateTime(2022, 9, 1),
    sortProposals: {},
    variants: [],
  ),
  Product(
    id: '145697',
    name: 'Napój energetyczny',
    photoSmall: 'monster',
    symbols: [],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(name: 'Puszka', container: ElementContainer.plastic, description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: '2',
    sortProposals: {},
    user: '1',
    addedDate: DateTime(2022, 9, 2),
    variants: [],
  ),
  Product(
    id: '1234567890128',
    name: 'Chusteczki',
    photoSmall: 'chusteczki',
    symbols: ['budlC2aRgOumb2c0RsQL', '6EudWBDUR1T8zgoqoYVl'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
        SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
      ],
    ),
    verifiedBy: '2',
    user: '1',
    addedDate: DateTime(2022, 9, 3),
    sortProposals: {},
    variants: [
      'Chusteczki 90 szt.',
      'Chusteczki 150 szt.',
    ],
  ),
  Product(
    id: '547145',
    name: 'Chusteczki',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F547145%2Foriginal.jpg?alt=media&token=3b7d4528-30b1-4d42-9a85-c69e9de913a1',
    photoSmall:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F547145%2Fsmall.jpg?alt=media&token=0c76315c-340f-44ed-a490-ae5af2deb1f6',
    symbols: ['budlC2aRgOumb2c0RsQL', '6EudWBDUR1T8zgoqoYVl'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
        SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
      ],
    ),
    verifiedBy: '2',
    user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
    addedDate: DateTime(2022, 9, 3),
    sortProposals: {},
    variants: [
      '547146',
      '547147',
    ],
  ),
  Product(
    id: '547146',
    name: 'Chusteczki 90 szt.',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F547145%2Foriginal.jpg?alt=media&token=3b7d4528-30b1-4d42-9a85-c69e9de913a1',
    photoSmall:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F547145%2Fsmall.jpg?alt=media&token=0c76315c-340f-44ed-a490-ae5af2deb1f6',
    symbols: ['budlC2aRgOumb2c0RsQL', '6EudWBDUR1T8zgoqoYVl'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
        SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
      ],
    ),
    verifiedBy: '2',
    user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
    addedDate: DateTime(2022, 9, 3),
    sortProposals: {},
    variants: [
      '547145',
      '547147',
    ],
  ),
  Product(
    id: '547147',
    name: 'Chusteczki 150 szt.',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F547145%2Foriginal.jpg?alt=media&token=3b7d4528-30b1-4d42-9a85-c69e9de913a1',
    photoSmall:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F547145%2Fsmall.jpg?alt=media&token=0c76315c-340f-44ed-a490-ae5af2deb1f6',
    symbols: ['budlC2aRgOumb2c0RsQL', '6EudWBDUR1T8zgoqoYVl'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
        SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
      ],
    ),
    verifiedBy: '2',
    user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
    addedDate: DateTime(2022, 9, 3),
    sortProposals: {},
    variants: [
      '547145',
      '547146',
    ],
  ),
  Product(
    id: '025896',
    name: 'Papier toaletowy',
    symbols: [],
    sortProposals: {},
    user: '1',
    addedDate: DateTime(2022, 9, 4),
    variants: [],
  ),
  Product(
    id: '254896',
    name: 'Butelka',
    symbols: [],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(container: ElementContainer.glass, name: 'Butelka'),
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
      ],
    ),
    user: '2',
    addedDate: DateTime(2022, 9, 5),
    sortProposals: {},
    variants: [],
  ),
  Product(
    id: '485768',
    name: 'Ręcznik papierowy',
    photoSmall: 'papier',
    symbols: ['budlC2aRgOumb2c0RsQL', '6EudWBDUR1T8zgoqoYVl'],
    sortProposals: {
      '1': Sort(
        id: '1',
        user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
        elements: [
          SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
          SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
        ],
        voteBalance: 0,
        votes: [],
      ),
    },
    user: '1',
    addedDate: DateTime(2022, 9, 6),
    variants: [],
  ),
  Product(
    id: '485769',
    name: 'Pieczywo',
    symbols: [],
    sortProposals: {
      '1': Sort(
        id: '1',
        user: 'laCdqVLmRZL8qJDQeiPn',
        elements: [
          SortElement(name: 'Pieczywo', container: ElementContainer.bio),
        ],
        voteBalance: 1,
        votes: [
          Vote(
            user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
            value: true,
          ),
        ],
      ),
    },
    user: '1',
    addedDate: DateTime(2022, 9, 7),
    variants: [],
  ),
  Product(
    id: '3547892',
    name: 'Woda niegazowana2',
    photoSmall: 'woda',
    symbols: ['budlC2aRgOumb2c0RsQL'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: 'xxx',
    user: '1',
    addedDate: DateTime(2022, 9, 1),
    sortProposals: {},
    variants: [],
  ),
  Product(
    id: '3547893',
    name: 'Woda niegazowana3',
    photoSmall: 'woda',
    symbols: ['budlC2aRgOumb2c0RsQL'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: 'xxx',
    user: '1',
    addedDate: DateTime(2022, 9, 1),
    sortProposals: {},
    variants: [],
  ),
  Product(
    id: '3547894',
    name: 'Woda niegazowana4',
    photoSmall: 'woda',
    symbols: ['budlC2aRgOumb2c0RsQL'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: 'xxx',
    user: '1',
    addedDate: DateTime(2022, 9, 1),
    sortProposals: {},
    variants: [],
  ),
  Product(
    id: '3547895',
    name: 'Woda niegazowana5',
    photoSmall: 'woda',
    symbols: ['budlC2aRgOumb2c0RsQL'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: 'xxx',
    user: '1',
    addedDate: DateTime(2022, 9, 1),
    sortProposals: {},
    variants: [],
  ),
  Product(
    id: '3547896',
    name: 'Woda niegazowana6',
    photoSmall: 'woda',
    symbols: ['budlC2aRgOumb2c0RsQL'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: 'xxx',
    user: '1',
    addedDate: DateTime(2022, 9, 1),
    sortProposals: {},
    variants: [],
  ),
  Product(
    id: '3547897',
    name: 'Woda niegazowana7',
    photoSmall: 'woda',
    symbols: ['budlC2aRgOumb2c0RsQL'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: 'xxx',
    user: '1',
    addedDate: DateTime(2022, 9, 1),
    sortProposals: {},
    variants: [],
  ),
  Product(
    id: '3547898',
    name: 'Woda niegazowana8',
    photoSmall: 'woda',
    symbols: ['budlC2aRgOumb2c0RsQL'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: 'xxx',
    user: '1',
    addedDate: DateTime(2022, 9, 1),
    sortProposals: {},
    variants: [],
  ),
  Product(
    id: '3547899',
    name: 'Woda niegazowana9',
    photoSmall: 'woda',
    symbols: ['budlC2aRgOumb2c0RsQL'],
    sort: Sort.verified(
      user: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: 'xxx',
    user: '1',
    addedDate: DateTime(2022, 9, 1),
    sortProposals: {},
    variants: [],
  ),
];
