import 'package:config_moodle/data/datasources/local_datasource.dart';
import 'package:config_moodle/data/repositories/config_repository_impl.dart';
import 'package:config_moodle/domain/entities/course_config.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryDatasource extends LocalDatasource {
  final _store = <String, CourseConfig>{};

  @override
  Future<List<CourseConfig>> getAll() async => _store.values.toList();

  @override
  Future<CourseConfig?> getById(String id) async => _store[id];

  @override
  Future<void> save(CourseConfig config) async {
    _store[config.id] = config;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }
}

void main() {
  test('imports spreadsheet exported by the app', () async {
    final datasource = _MemoryDatasource();
    final repo = ConfigRepositoryImpl(datasource);
    final config = CourseConfig(
      id: 'cfg',
      name: 'Instrumentacao',
      moodleCourseId: 123,
      moodleCourseName: 'Instrumentacao Industrial',
      semesterStartDate: DateTime(2026, 2, 16),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      sections: [
        SectionEntry(
          id: 's1',
          orderIndex: 1,
          name: 'BLOCO 01',
          referenceDaysOffset: 0,
          date: DateTime(2026, 2, 16),
          offsetDays: 0,
          moodleSectionId: 10,
          moodleDescription: 'Descricao',
          activities: [
            ActivityEntry(
              id: 'a1',
              name: 'Prática 01',
              activityType: 'URL',
              openOffsetDays: 0,
              moodleModuleId: 20,
            ),
          ],
        ),
      ],
    );
    await datasource.save(config);

    final bytes = await repo.exportToSpreadsheetBytes(config.id);
    final imported = repo.parseSpreadsheetBytes(bytes);

    expect(imported, hasLength(1));
    expect(imported.single.sections, hasLength(1));
    expect(imported.single.sections.single.activities, hasLength(1));
    expect(imported.single.moodleCourseId, 123);
  });
}
