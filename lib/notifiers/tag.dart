import 'package:flutter/foundation.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/repositories/tag.dart';

class TagNotifier extends ChangeNotifier {
  final TagRepository repository;
  List<Tag> tags = [];

  TagNotifier({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    await repository.ready;
    await loadAll();
  }

  Future<void> loadAll() async {
    tags = await repository.allTags();
    notifyListeners();
  }

  Future<void> create(Tag tag) async {
    await repository.insertTag(tag);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await repository.deleteTag(id);
    await loadAll();
  }

  Future<void> update(Tag tag) async {
    await repository.updateTag(tag);
    await loadAll();
  }

  Future<Tag> getById(int id) async => repository.getTag(id);
}
