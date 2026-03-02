import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/features/tags/models/tag.dart';
import 'package:supporttickets_app/features/tags/repositories/tag_repository.dart';
import 'package:supporttickets_app/features/tags/viewmodels/tag_management_viewmodel.dart';

class FakeTagRepository extends Fake implements TagRepository {
  List<Tag> tags = [Tag(id: 1, name: 'Bug', color: '#FF0000')];

  @override
  Future<List<Tag>> getTags() async => List.from(tags); // Fixes pointer leak

  @override
  Future<Tag> createTag(String name, String? color) async {
    final newTag = Tag(id: 2, name: name, color: color);
    tags.add(newTag);
    return newTag;
  }

  @override
  Future<void> deleteTag(int id) async {
    tags.removeWhere((t) => t.id == id);
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