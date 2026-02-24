import 'package:flutter/foundation.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/repositories/breathing.dart';

class BreathingNotifier extends ChangeNotifier {
  final BreathingRepository repository;
  List<Breathing> breathings = [];
  final Map<int, List<int>> _tagCache = {};

  BreathingNotifier({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    await repository.ready;
    await loadAll();
  }

  Future<void> loadAll() async {
    breathings = await repository.allBreathing();
    for (Breathing breathing in breathings) {
      _tagCache[breathing.id] = await repository.tagsForBreathing(breathing.id);
    }
    notifyListeners();
  }

  Future<Breathing> create(Breathing t) async {
    final Breathing created = await repository.insertBreathing(t);
    await loadAll();
    return created;
  }

  Future<void> delete(int id) async {
    await repository.deleteBreathing(id);
    await loadAll();
  }

  Future<void> update(Breathing t) async {
    await repository.updateBreathing(t);
    await loadAll();
  }

  Future<void> addTag(int breathingID, int tagID) async {
    await repository.addTag(breathingID, tagID);
    await loadAll();
  }

  Future<void> removeTag(int breathingID, int tagID) async {
    await repository.removeTag(breathingID, tagID);
    await loadAll();
  }

  List<int> getTags(Breathing breathing) {
    return _tagCache[breathing.id] ?? [];
  }

  Future<void> setTags(Breathing breathing, List<int> tagIDs) async {
    List<int> currentTags = getTags(breathing);
    final Set<int> currentTagSet = currentTags.toSet();
    final Set<int> tagIdSet = tagIDs.toSet();

    // note we are calling the repository version
    // so we avoid constantly calling loadAll()
    for (int tagID in currentTags) {
      if (!tagIdSet.contains(tagID)) {
        await repository.removeTag(breathing.id, tagID);
      }
    }
    for (int tagID in tagIDs) {
      if (!currentTagSet.contains(tagID)) {
        await repository.addTag(breathing.id, tagID);
      }
    }
    await loadAll();
  }

  Future<Breathing> getById(int id) async => repository.getBreathing(id);
}
