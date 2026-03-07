import 'package:flutter/foundation.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/repositories/tag.dart';

/// State management for the user's [Tag] collection.
///
/// [TagNotifier] extends [ChangeNotifier] and is exposed to the widget tree
/// via `provider`. Widgets consume [tags] to render colour chips and subscribe
/// to updates via [addListener] / `context.watch`.
///
/// All mutating methods persist the change through the injected [TagRepository]
/// and then call [loadAll] to refresh [tags] and notify listeners.
class TagNotifier extends ChangeNotifier {
  /// The repository used for all tag persistence operations.
  final TagRepository repository;

  /// The current list of tags, refreshed after every mutation.
  List<Tag> tags = [];

  /// Creates a [TagNotifier] and immediately begins loading data from
  /// [repository] once it signals readiness.
  TagNotifier({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    await repository.ready;
    await loadAll();
  }

  /// Fetches all tags from the repository and refreshes [tags].
  ///
  /// Listeners are notified once loading completes.
  Future<void> loadAll() async {
    tags = await repository.allTags();
    notifyListeners();
  }

  /// Persists [tag] to the repository and refreshes [tags].
  Future<void> create(Tag tag) async {
    await repository.insertTag(tag);
    await loadAll();
  }

  /// Permanently removes the tag with [id] and refreshes [tags].
  Future<void> delete(int id) async {
    await repository.deleteTag(id);
    await loadAll();
  }

  /// Overwrites the stored tag that matches [tag.id] with updated field values,
  /// then refreshes [tags].
  Future<void> update(Tag tag) async {
    await repository.updateTag(tag);
    await loadAll();
  }

  /// Returns the tag with the given [id] directly from the repository.
  Future<Tag> getById(int id) async => repository.getTag(id);
}
