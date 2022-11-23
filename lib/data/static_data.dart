// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:collection/collection.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/models/product/sort_element_template.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';

List<AppUser> users = [
  AppUser(
    id: '1',
    email: '1',
    name: 'Wojtek',
    surname: 'Brandeburg',
    role: Role.mod,
    signUpDate: FirestoreDateTime.serverTimestamp(),
  ),
  AppUser(
    id: '2',
    email: '2',
    name: 'Michał',
    surname: 'Marciniak',
    role: Role.user,
    signUpDate: FirestoreDateTime.serverTimestamp(),
  ),
];

AppUser? getUser(String? email) {
  if (email != null) return users.firstWhereOrNull((element) => element.email == email);
  return null;
}

final symbols = [
  const ProductSymbol(
    id: 'Q5pJVrUTCUB6gQaGFwZs',
    name: '01 PET',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/symbols%2Fpet.png?alt=media&token=58bb7f7b-0ed0-48b5-a32e-f6b901d42795',
    description: 'Politereftalan Etylenu, zdatny do recyklingu.',
  ),
  const ProductSymbol(
    id: 'budlC2aRgOumb2c0RsQL',
    name: '21 PAP',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/symbols%2Fpap.png?alt=media&token=17495d20-605a-4c1c-acc6-ad6df3f548e8',
    description: 'Materiał wykonany z włókien celulozy, zdatny do recyklingu i biodegradowalny.',
  ),
  const ProductSymbol(
    id: 'wDqeQrPtA0Y89UN293sI',
    name: '40 FE',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/symbols%2Ffe.png?alt=media&token=e26442c2-8513-42e9-a4d6-36320b66657e',
    description: 'Ferrum, materiał wykonany ze stali.',
  ),
  const ProductSymbol(
    id: 'E7dFfaXbKJ6EsrV1CS3Z',
    name: '41 ALU',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/symbols%2Falu.png?alt=media&token=4af176d9-218c-49fe-86f2-f3a110d2a67d',
    description: 'Aluminium, materiał wykonany z aluminium.',
  ),
  const ProductSymbol(
    id: '6EudWBDUR1T8zgoqoYVl',
    name: 'Dbaj o czystość',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/symbols%2Fclean.png?alt=media&token=6b0d3093-4545-458e-9842-75491c53e4fa',
    description: 'Opakowanie wyrzuć do kosza',
  ),
];

final sortElementTemplates = [
  SortElementTemplate(
    id: 'FYonJ12qORTDYwI2Ybme',
    container: ElementContainer.plastic,
    name: 'Puszka',
    description: 'Zgnieć przed wyrzuceniem',
  ),
  SortElementTemplate(
    id: 'My7qDCiIAwnyh3yoacm4',
    container: ElementContainer.plastic,
    name: 'Nakrętka',
    description: 'Odkręć i wyrzuć oddzielnie',
  ),
  SortElementTemplate(
    id: 'HlTnEW9ZyG2aNIfMhZeJ',
    container: ElementContainer.plastic,
    name: 'Butelka',
    description: 'Zgnieć przed wyrzuceniem',
  ),
  SortElementTemplate(
    id: 'LE7CrnurQijsFTdiS7gx',
    container: ElementContainer.paper,
    name: 'Opakowanie',
    description: 'Zgnieć przed wyrzuceniem',
  ),
  SortElementTemplate(
    id: 'p1ESXwmWi0ErTnxyBrIj',
    container: ElementContainer.plastic,
    name: 'Folia',
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
    addedDate: FirestoreDateTime(2022, 9, 1),
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
    addedDate: FirestoreDateTime(2022, 9, 2),
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
    addedDate: FirestoreDateTime(2022, 9, 3),
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
    addedDate: FirestoreDateTime(2022, 9, 3),
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
    addedDate: FirestoreDateTime(2022, 9, 3),
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
    addedDate: FirestoreDateTime(2022, 9, 3),
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
    addedDate: FirestoreDateTime(2022, 9, 4),
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
    addedDate: FirestoreDateTime(2022, 9, 5),
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
        votes: {},
      ),
    },
    user: '1',
    addedDate: FirestoreDateTime(2022, 9, 6),
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
          votes: {
            'VJHS5rQwHxh08064vjhkMhes2lS2': true,
          }),
    },
    user: '1',
    addedDate: FirestoreDateTime(2022, 9, 7),
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
    addedDate: FirestoreDateTime(2022, 9, 1),
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
    addedDate: FirestoreDateTime(2022, 9, 1),
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
    addedDate: FirestoreDateTime(2022, 9, 1),
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
    addedDate: FirestoreDateTime(2022, 9, 1),
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
    addedDate: FirestoreDateTime(2022, 9, 1),
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
    addedDate: FirestoreDateTime(2022, 9, 1),
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
    addedDate: FirestoreDateTime(2022, 9, 1),
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
    addedDate: FirestoreDateTime(2022, 9, 1),
    sortProposals: {},
    variants: [],
  ),

  // real data
  Product(
    id: '5902078020001',
    name: 'Cisowianka Lekko Gazowana',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F5902078020001%2Foriginal.png?alt=media&token=870a7026-8eef-4a2b-86f1-4f2dfe29a27a',
    photoSmall:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F5902078020001%2Fsmall.png?alt=media&token=588623fb-dc72-419b-b18e-ea3f45527dff',
    sort: Sort.verified(
      user: 'qVVAflMZhcRttgVqI0hFfoHj0043',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem'),
      ],
    ),
    verifiedBy: 'VJHS5rQwHxh08064vjhkMhes2lS2',
    user: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
    addedDate: FirestoreDateTime(2022, 10, 6, 12, 51),
  ),
  Product(
    id: '5900579259227',
    name: 'Queen Chusteczki dwuwarstwowe 150 szt.',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F5900579259227%2Foriginal.png?alt=media&token=2311d5a3-862d-44da-974c-f926e8a33766',
    photoSmall:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F5900579259227%2Fsmall.png?alt=media&token=3c8ba97f-e34e-4d34-8d25-3bf01918af19',
    sort: Sort.verified(
      user: 'qVVAflMZhcRttgVqI0hFfoHj0043',
      elements: [
        SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
        SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed),
      ],
    ),
    variants: ['5900579259210'],
    verifiedBy: 'VJHS5rQwHxh08064vjhkMhes2lS2',
    user: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
    addedDate: FirestoreDateTime(2022, 10, 6, 13, 8),
  ),
  Product(
    id: '5900579259210',
    name: 'Queen Chusteczki dwuwarstwowe 150 szt.',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F5900579259210%2Foriginal.png?alt=media&token=2311d5a3-862d-44da-974c-f926e8a33766',
    photoSmall:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F5900579259210%2Fsmall.png?alt=media&token=3c8ba97f-e34e-4d34-8d25-3bf01918af19',
    sort: Sort.verified(
      user: 'qVVAflMZhcRttgVqI0hFfoHj0043',
      elements: [
        SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
        SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed),
      ],
    ),
    variants: ['5900579259227'],
    verifiedBy: 'VJHS5rQwHxh08064vjhkMhes2lS2',
    user: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
    addedDate: FirestoreDateTime(2022, 10, 6, 13, 30),
  ),
  Product(
    id: '5901588016443',
    name: 'Wedel Czekolada Mleczna Truskawkowa',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F5901588016443%2Foriginal.png?alt=media&token=0097026f-fd6c-4490-9026-084d58859787',
    photoSmall:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F5901588016443%2Fsmall.png?alt=media&token=64a39a17-07ec-4571-8817-020817674d94',
    sortProposals: {
      '1': Sort(
        id: '1',
        user: 'qVVAflMZhcRttgVqI0hFfoHj0043',
        elements: [
          SortElement(container: ElementContainer.plastic, name: 'Opakowanie'),
        ],
        voteBalance: 0,
        votes: {},
      ),
    },
    user: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
    addedDate: FirestoreDateTime(2022, 10, 6, 13, 40),
  ),
  Product(
    id: '4000735235506',
    name: 'Queen Strong Ręczniki kuchenne 2szt.',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F4000735235506%2Foriginal.png?alt=media&token=017562d7-9cec-4385-92e2-ff15ddc501d4',
    photoSmall:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F4000735235506%2Fsmall.png?alt=media&token=2f708b51-ee4d-4ff2-aa2d-9553c983f068',
    symbols: ['6EudWBDUR1T8zgoqoYVl'],
    user: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
    addedDate: FirestoreDateTime(2022, 10, 7, 15, 49),
  ),
  Product(
    id: '5906764644366',
    name: 'ECO Ściereczki wiskozowe perforowane 5szt.',
    photo:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F5906764644366%2Foriginal.png?alt=media&token=b7d8410e-0b51-471f-803c-8e662fe6466b',
    photoSmall:
        'https://firebasestorage.googleapis.com/v0/b/inzynierka-7f9f7.appspot.com/o/products%2F5906764644366%2Fsmall.png?alt=media&token=2a9f280e-5f2c-4e80-a0f0-6c931b231b4b',
    symbols: ['6EudWBDUR1T8zgoqoYVl'],
    user: 'qVVAflMZhcRttgVqI0hFfoHj0043',
    addedDate: FirestoreDateTime(2022, 10, 7, 15, 49),
  )
];
