import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/models/product/sort_element_template.dart';
import 'package:inzynierka/repositories/sort_element_template_repository.dart';
import 'package:inzynierka/screens/widgets/sort_elements_input.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'sort_elements_input_test.mocks.dart';

class MockOnElementsChanged extends Mock {
  void call(SortElements elements) => super.noSuchMethod(Invocation.method(#call, [elements]));
}

@GenerateNiceMocks([MockSpec<SortElementTemplateRepository>()])
void main() {
  const selectedContainer = ElementContainer.plastic;
  final templates = [
    SortElementTemplate(id: '1', container: ElementContainer.plastic, name: 'Butelka'),
    SortElementTemplate(id: '2', container: ElementContainer.paper, name: 'Opakowanie')
  ];
  final selectedContainerTemplates = templates.where((element) => element.container == selectedContainer).toList();
  late MockSortElementTemplateRepository mockSortElementTemplateRepository;
  late MockOnElementsChanged mockOnElementsChanged;

  buildNewElementWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        SingleChildScrollView(
          child: SortElementsInput(
              elements: const {selectedContainer: []}, onElementsChanged: mockOnElementsChanged, required: true),
        ),
        overrides: [
          sortElementTemplateRepositoryProvider.overrideWithValue(mockSortElementTemplateRepository),
          allSortElementTemplatesProvider.overrideWithValue(templates),
        ],
      ),
    );

    await scrollToAndTap(tester, find.text('Dodaj element'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    mockSortElementTemplateRepository = MockSortElementTemplateRepository();
    mockOnElementsChanged = MockOnElementsChanged();
  });

  testWidgets('Should not save when name is empty', (tester) async {
    await buildNewElementWidget(tester);

    await scrollToAndTap(tester, find.text('Zapisz element'));
    await tester.pumpAndSettle();

    expect(find.text('Nowy element'), findsOneWidget);
  });

  testWidgets('Should save when description is empty', (tester) async {
    const name = 'Element';
    await buildNewElementWidget(tester);

    await tester.enterText(find.bySemanticsLabel('Nazwa'), name);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Zapisz element'));
    await tester.pumpAndSettle();

    expect(find.text('Nowy element'), findsNothing);
    verify(
      mockOnElementsChanged.call({
        selectedContainer: [SortElement(container: selectedContainer, name: name)],
      }),
    );
  });

  testWidgets('Should save element with description', (tester) async {
    const name = 'Element';
    const desc = 'Description';
    await buildNewElementWidget(tester);

    await tester.enterText(find.bySemanticsLabel('Nazwa'), name);
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('Dodatkowe informacje'), desc);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Zapisz element'));
    await tester.pumpAndSettle();

    expect(find.text('Nowy element'), findsNothing);
    verify(
      mockOnElementsChanged.call({
        selectedContainer: [SortElement(container: selectedContainer, name: name, description: desc)],
      }),
    );
  });

  testWidgets('Should save element chosen from templates list', (tester) async {
    final template = selectedContainerTemplates.first;
    await buildNewElementWidget(tester);

    await scrollToAndTap(tester, find.bySemanticsLabel('Wybierz z listy'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel(template.name).first);
    await tester.pumpAndSettle();

    expect(find.text('Nowy element'), findsNothing);
    verify(
      mockOnElementsChanged.call({
        selectedContainer: [SortElement(container: selectedContainer, name: template.name, description: template.description)],
      }),
    );
  });

  testWidgets('Should close element modal on tap', (tester) async {
    await buildNewElementWidget(tester);

    await scrollToAndTap(tester, find.text('Cofnij'));
    await tester.pumpAndSettle();

    expect(find.text('Nowy element'), findsNothing);
  });
}
