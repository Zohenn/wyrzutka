import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sort.dart';
import '../models/sortElement.dart';
import '../models/symbol.dart';
import '../models/app_user.dart';

List<AppUser> users = [
  const AppUser(email: "1", name: "Wojtek", surname: "Brandeburg"),
  const AppUser(email: "2", name: "Michał", surname: "Marciniak"),
];

AppUser? getUser(String? email) {
  if (email != null) return users.firstWhereOrNull((element) => element.email == email);
  return null;
}

final symbols = [
  const Symbol(id: "1", name: "Tektura", photo: "", description: "Opakowanie wykonane z tektury"),
  const Symbol(id: "2", name: "Dbaj o czystość", photo: "", description: "Opakowanie wyrzuć do kosza"),
];

IconData getIconByString(String symbol) {
  switch (symbol) {
    default:
      return Icons.question_mark;
  }
}

Symbol? getSymbol(String name) {
  return symbols.firstWhereOrNull((element) => element.id == name);
}

final productsList = [
  const Product(
    id: 354789,
    name: "Woda niegazowana",
    photo: "woda",
    symbols: [],
    sort: Sort(elements: [
      SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
      SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
    ]),
    verifiedBy: 'xxx',
    containers: ['plastic'],
    user: "1",
    sortProposals: [],
    variants: [],
  ),
  const Product(
    id: 145697,
    name: "Napój energetyczny",
    symbols: [],
    sort: Sort(
      elements: [
        SortElement(name: 'Puszka', container: ElementContainer.plastic, description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    verifiedBy: '2',
    containers: ['plastic'],
    sortProposals: [],
    user: "1",
    variants: [],
  ),
  const Product(
    id: 547145,
    name: "Chusteczki",
    symbols: ["1", "2"],
    sort: Sort(
      elements: [
        SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
        SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
      ],
    ),
    verifiedBy: '2',
    containers: ['paper', 'mixed'],
    user: "1",
    sortProposals: [],
    variants: [
      "Chusteczki 90 szt.",
      "Chusteczki 150 szt.",
    ],
  ),
  const Product(
    id: 025896,
    name: "Papier toaletowy",
    symbols: [],
    sortProposals: [],
    user: "1",
    variants: [],
  ),
  const Product(
    id: 254896,
    name: "Frugo",
    symbols: [],
    sort: Sort(
      elements: [
        SortElement(name: 'Puszka', container: ElementContainer.plastic, description: 'Zgnieć przed wyrzuceniem')
      ],
    ),
    user: "2",
    sortProposals: [],
    variants: [],
  ),
  const Product(
    id: 485769,
    name: "Ręcznik papierowy",
    symbols: ["1", "2"],
    sortProposals: [
      Sort(
        elements: [
          SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
          SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
        ],
      )
    ],
    user: "1",
    variants: [],
  ),
  const Product(
    id: 485769,
    name: "Ręcznik papierowy",
    symbols: ["1", "2"],
    sortProposals: [],
    user: "1",
    variants: [],
  ),
];
