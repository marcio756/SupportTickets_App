import 'package:flutter/foundation.dart';
import '../models/tag.dart';
import '../repositories/tag_repository.dart';

/// Manages state for the Tag Management screen.
class TagManagementViewModel extends ChangeNotifier {
  final TagRepository repository;

  List<Tag> _tags = [];
  bool _isLoading = false;
  String? _errorMessage;

  TagManagementViewModel({required this.repository});

  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTags() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawTags = await repository.getTags();
      _tags = rawTags.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTag(String name, String? color) async {
    try {
      final response = await repository.createTag({'name': name, 'color': color});
      final newTag = Tag.fromJson(response);
      _tags.add(newTag);
      _tags.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTag(int id, String name, String? color) async {
    try {
      final response = await repository.updateTag(id, {'name': name, 'color': color});
      final updatedTag = Tag.fromJson(response);
      final index = _tags.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tags[index] = updatedTag;
        _tags.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTag(int id) async {
    try {
      await repository.deleteTag(id);
      _tags.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}