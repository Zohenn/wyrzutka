import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wyrzutka/models/product/sort_element.dart';
import 'package:wyrzutka/models/product/sort_element_template.dart';
import 'package:wyrzutka/repositories/sort_element_template_repository.dart';
import 'package:wyrzutka/screens/widgets/sort_elements_input.dart';
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
  final element = SortElement(container: selectedContainer, name: 'Element name', description: 'Desc');
  late MockSortElementTemplateRepository mockSortElementTemplateRepository;
  late MockOnElementsChanged mockOnElementsChanged;

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        SingleChildScrollView(
          child: SortElementsInput(
            elements: const {},
            onElementsChanged: mockOnElementsChanged,
            required: true,
          ),
        ),
        overrides: [
          sortElementTemplateRepositoryProvider.overrideWithValue(mockSortElementTemplateRepository),
          allSortElementTemplatesProvider.overrideWithValue(templates),
        ],
      ),
    );
  }

  buildWidgetWithSelectedContainer(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        SingleChildScrollView(
          child: SortElementsInput(
            elements: const {selectedContainer: []},
            onElementsChanged: mockOnElementsChanged,
            required: true,
          ),
        ),
        overrides: [
          sortElementTemplateRepositoryProvider.overrideWithValue(mockSortElementTemplateRepository),
          allSortElementTemplatesProvider.overrideWithValue(templates),
        ],
      ),
    );
  }

  buildWidgetWithElement(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        SingleChildScrollView(
          child: SortElementsInput(
            elements: {
              selectedContainer: [element]
            },
            onElementsChanged: mockOnElementsChanged,
            required: true,
          ),
        ),
        overrides: [
          sortElementTemplateRepositoryProvider.overrideWithValue(mockSortElementTemplateRepository),
          allSortElementTemplatesProvider.overrideWithValue(templates),
        ],
      ),
    );
  }

  buildNewElementWidget(WidgetTester tester) async {
    await buildWidgetWithSelectedContainer(tester);

    await scrollToAndTap(tester, find.text('Dodaj element'));
    await tester.pumpAndSettle();
  }

  buildEditElementWidget(WidgetTester tester) async {
    await buildWidgetWithElement(tester);

    await scrollToAndTap(tester, find.byTooltip('Edytuj element'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    mockSortElementTemplateRepository = MockSortElementTemplateRepository();
    mockOnElementsChanged = MockOnElementsChanged();
  });

  testWidgets('Should emit change event when container is selected', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text(selectedContainer.containerName));

    verify(mockOnElementsChanged.call({selectedContainer: []}));
  });

  testWidgets('Should emit change event when container is deselected', (tester) async {
    await buildWidgetWithSelectedContainer(tester);

    await scrollToAndTap(tester, find.text(selectedContainer.containerName).first);

    verify(mockOnElementsChanged.call({}));
  });

  testWidgets('Should emit change event when new element is added', (tester) async {
    await buildNewElementWidget(tester);

    final context = getContext(tester);
    Navigator.of(context).pop(ElementModel(element.name, element.description!));
    await tester.pumpAndSettle();

    verify(mockOnElementsChanged.call({
      selectedContainer: [element]
    }));
  });

  testWidgets('Should emit change event when element is edited', (tester) async {
    final elementAfterEdit = SortElement(
      container: selectedContainer,
      name: 'Edited name',
      description: 'Edited description',
    );
    await buildEditElementWidget(tester);

    final context = getContext(tester);
    Navigator.of(context).pop(ElementModel(elementAfterEdit.name, elementAfterEdit.description!));
    await tester.pumpAndSettle();

    verify(mockOnElementsChanged.call({
      selectedContainer: [elementAfterEdit]
    }));
  });
  
  testWidgets('Should emit change event when element is deleted', (tester) async {
    await buildWidgetWithElement(tester);

    await scrollToAndTap(tester, find.byTooltip('Usuń element'));
    await tester.pumpAndSettle();

    verify(mockOnElementsChanged.call({selectedContainer: []}));
  });

  group('element', () {
    testWidgets('Should show templates for selected container only', (tester) async {
      await buildNewElementWidget(tester);

      await scrollToAndTap(tester, find.bySemanticsLabel('Wybierz z listy'));
      await tester.pumpAndSettle();

      for (var template in templates) {
        final matcher = selectedContainerTemplates.contains(template) ? findsNWidgets(2) : findsNothing;
        expect(find.text(template.name), matcher);
      }
    });

    testWidgets('Should fill inputs when editing', (tester) async {
      await buildEditElementWidget(tester);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Nazwa')),
        matchesSemantics(value: element.name, hasTapAction: true, isTextField: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Dodatkowe informacje')),
        matchesSemantics(value: element.description, hasTapAction: true, isTextField: true),
      );
    });

    testWidgets('Should not show templates when editing', (tester) async {
      await buildEditElementWidget(tester);

      expect(find.text('Wybierz z listy'), findsNothing);
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
          selectedContainer: [
            SortElement(container: selectedContainer, name: template.name, description: template.description)
          ],
        }),
      );
    });

    testWidgets('Should close element modal on tap', (tester) async {
      await buildNewElementWidget(tester);

      await scrollToAndTap(tester, find.text('Cofnij'));
      await tester.pumpAndSettle();

      expect(find.text('Nowy element'), findsNothing);
    });
  });
}
