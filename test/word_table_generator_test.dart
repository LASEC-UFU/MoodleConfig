import 'package:config_moodle/data/word_table_generator.dart';
import 'package:config_moodle/domain/entities/course_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generateTsv filters practice rows and selected columns', () {
    final config = _sampleConfig();

    final text = WordTableGenerator.generateTsv(
      config,
      const WordTableOptions(
        preset: WordTablePreset.practice,
        columns: {
          WordTableColumn.date,
          WordTableColumn.modality,
          WordTableColumn.classGroup,
          WordTableColumn.taughtSubject,
        },
      ),
    );

    expect(text, contains('Data\tModalidade\tTurma\tMatéria Lecionada'));
    expect(text, contains('16/02/2026\tPrática\tT\tPrática 01 - Bancada'));
    expect(text, isNot(contains('Teoria 01')));
  });

  test('generateHtml marks theory and special rows', () {
    final config = _sampleConfig();

    final html = WordTableGenerator.generateHtml(
      config,
      const WordTableOptions(
        preset: WordTablePreset.theory,
        columns: {WordTableColumn.date, WordTableColumn.taughtSubject},
        onlyMatchingModality: false,
      ),
    );

    expect(html, contains('class="theory special"'));
    expect(html, contains('2ª Prova'));
  });
}

CourseConfig _sampleConfig() {
  final now = DateTime(2026);
  return CourseConfig(
    id: 'cfg',
    name: 'Teste',
    semesterStartDate: now,
    createdAt: now,
    updatedAt: now,
    sections: [
      SectionEntry(
        id: 's1',
        orderIndex: 1,
        name: 'Prática 01 - Bancada',
        referenceDaysOffset: 0,
        date: DateTime(2026, 2, 16),
        offsetDays: 0,
      ),
      SectionEntry(
        id: 's2',
        orderIndex: 2,
        name: 'Teoria 01 - Segurança',
        referenceDaysOffset: 1,
        date: DateTime(2026, 2, 17),
        offsetDays: 1,
      ),
      SectionEntry(
        id: 's3',
        orderIndex: 3,
        name: 'Teórica - 2ª Prova',
        referenceDaysOffset: 2,
        date: DateTime(2026, 2, 18),
        offsetDays: 2,
      ),
    ],
  );
}
