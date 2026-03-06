import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/features/tags/repositories/tag_repository.dart';
import 'package:supporttickets_app/features/tags/viewmodels/tag_management_viewmodel.dart';

class FakeTagRepository extends Fake implements TagRepository {
  List<Map<String, dynamic>> tags = [{'id': 1, 'name': 'Bug', 'color': '#FF0000'}];

  @override
  Future<List<Map<String, dynamic>>> getTags() async => List.from(tags);

  @override
  Future<Map<String, dynamic>> createTag(Map<String, dynamic> tagData) async {
    final newTag = {'id': 2, 'name': tagData['name'], 'color': tagData['color']};
    tags.add(newTag);
    return newTag;
  }
  
  @override
  Future<Map<String, dynamic>> updateTag(int id, Map<String, dynamic> tagData) async {
    final updatedTag = {'id': id, 'name': tagData['name'], 'color': tagData['color']};
    final index = tags.indexWhere((t) => t['id'] == id);
    if(index != -1) tags[index] = updatedTag;
    return updatedTag;
  }

  @override
  Future<void> deleteTag(int id) async {
    tags.removeWhere((t) => t['id'] == id);
  }
}

void main() {
  late TagManagementViewModel viewModel;
  late FakeTagRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeTagRepository();
    viewModel = TagManagementViewModel(repository: fakeRepository);
  });

  group('TagManagementViewModel - TDD', () {
    test('Must load initial tags from repository', () async {
      await viewModel.loadTags();
      expect(viewModel.tags.length, 1);
      expect(viewModel.tags.first.name, 'Bug');
      expect(viewModel.isLoading, false);
    });

    test('Must add new tag and update state list', () async {
      await viewModel.loadTags();
      final success = await viewModel.createTag('Feature', '#00FF00');
      
      expect(success, true);
      expect(viewModel.tags.length, 2);
      expect(viewModel.tags.last.name, 'Feature');
    });

    test('Must delete tag and remove from state', () async {
      await viewModel.loadTags();
      final success = await viewModel.deleteTag(1);
      
      expect(success, true);
      expect(viewModel.tags.isEmpty, true);
    });
  });
}