// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:collection/collection.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/models/sort.dart';
import 'package:inzynierka/models/sort_element.dart';
import 'package:inzynierka/models/symbol.dart';

List<AppUser> users = [
  const AppUser(email: '1', name: 'Wojtek', surname: 'Brandeburg'),
  const AppUser(email: '2', name: 'Michał', surname: 'Marciniak'),
];

AppUser? getUser(String? email) {
  if (email != null) return users.firstWhereOrNull((element) => element.email == email);
  return null;
}

final symbols = [
  const Symbol(id: 'pap', name: 'Tektura', photo: '', description: 'Opakowanie wykonane z tektury'),
  const Symbol(id: 'clean', name: 'Dbaj o czystość', photo: '', description: 'Opakowanie wyrzuć do kosza'),
];

Symbol? getSymbol(String name) {
  return symbols.firstWhereOrNull((element) => element.id == name);
}

final productsList = [
  Product(
    id: '354789',
    name: 'Woda niegazowana',
    photo: 'woda',
    symbols: ['pap'],
    sort: Sort(elements: [
      SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
      SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
    ]),
    verifiedBy: 'xxx',
    containers: ['plastic'],
    user: '1',
    addedDate: DateTime(2022, 9, 1),
    sortProposals: [],
    variants: [],
  ),
  Product(
    id: '145697',
    name: 'Napój energetyczny',
    photo: 'monster',
    symbols: [],
    sort: Sort(
      elements: [
        SortElement(name: 'Puszka', container: ElementContainer.plastic, description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: '2',
    containers: ['plastic'],
    sortProposals: [],
    user: '1',
    addedDate: DateTime(2022, 9, 2),
    variants: [],
  ),
  Product(
    id: '547145',
    name: 'Chusteczki',
    photo: 'chusteczki',
    symbols: ['pap', 'clean'],
    sort: Sort(
      elements: [
        SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
        SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
      ],
    ),
    verifiedBy: '2',
    containers: ['paper', 'mixed'],
    user: '1',
    addedDate: DateTime(2022, 9, 3),
    sortProposals: [],
    variants: [
      'Chusteczki 90 szt.',
      'Chusteczki 150 szt.',
    ],
  ),
  Product(
    id: '025896',
    name: 'Papier toaletowy',
    symbols: [],
    sortProposals: [],
    user: '1',
    addedDate: DateTime(2022, 9, 4),
    variants: [],
  ),
  Product(
    id: '254896',
    name: 'Butelka',
    symbols: [],
    sort: Sort(
      elements: [
        SortElement(container: ElementContainer.glass, name: 'Butelka'),
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
      ],
    ),
    user: '2',
    addedDate: DateTime(2022, 9, 5),
    sortProposals: [],
    variants: [],
  ),
  Product(
    id: '485769',
    name: 'Ręcznik papierowy',
    photo: 'papier',
    symbols: ['pap', 'clean'],
    sortProposals: [
      Sort(
        elements: [
          SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
          SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
        ],
      )
    ],
    user: '1',
    addedDate: DateTime(2022, 9, 6),
    variants: [],
  ),
  Product(
    id: '485769',
    name: 'Pieczywo',
    symbols: [],
    sortProposals: [
      Sort(
        elements: [
          SortElement(name: 'Pieczywo', container: ElementContainer.bio)
        ],
      )
    ],
    user: '1',
    addedDate: DateTime(2022, 9, 7),
    variants: [],
  ),
];
