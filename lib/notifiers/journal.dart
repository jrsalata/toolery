import 'package:flutter/foundation.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/repositories/journal.dart';

/// State management for the user's [Journal] entry collection.
///
/// [JournalNotifier] extends [ChangeNotifier] and is exposed to the widget tree
/// via `provider`. Widgets consume [entries] to render lists and subscribe to
/// updates via [addListener] / `context.watch`.
///
/// All mutating methods persist the change through the injected
/// [JournalRepository] and then call [loadAll] to refresh [entries] and notify
/// listeners.
///
/// Tag associations are lazily cached in [_tagCache] to avoid redundant
/// database round-trips on every rebuild.
class JournalNotifier extends ChangeNotifier {
  /// The repository used for all journal persistence operations.
  final JournalRepository repository;

  /// The current list of entries, refreshed after every mutation.
  List<Journal> entries = [];

  // Internal cache mapping entry id → list of associated tag ids.
  final Map<int, List<int>> _tagCache = {};

  /// Creates a [JournalNotifier] and immediately begins loading data from
  /// [repository] once it signals readiness.
  JournalNotifier({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    await repository.ready;
    await loadAll();
  }

  /// Fetches all entries from the repository and refreshes [entries].
  ///
  /// Also repopulates the internal tag cache. Listeners are notified once
  /// loading completes.
  Future<void> loadAll() async {
    entries = await repository.allEntries();
    for (Journal entry in entries) {
      _tagCache[entry.id] = await repository.tagsForEntry(entry.id);
    }
    notifyListeners();
  }

  /// Persists [entry] and returns the saved copy (with its database-assigned id).
  ///
  /// [entries] is refreshed and listeners are notified after insertion.
  Future<Journal> create(Journal entry) async {
    final Journal created = await repository.insertEntry(entry);
    await loadAll();
    return created;
  }

  /// Permanently removes the entry with [id] and refreshes [entries].
  Future<void> delete(int id) async {
    await repository.deleteEntry(id);
    await loadAll();
  }

  /// Overwrites the stored entry that matches [entry.id] with updated field values,
  /// then refreshes [entries].
  Future<void> update(Journal entry) async {
    await repository.updateEntry(entry);
    await loadAll();
  }

  /// Links the tag [tagID] to [entryID] and refreshes [entries].
  Future<void> addTag(int entryID, int tagID) async {
    await repository.addTag(entryID, tagID);
    await loadAll();
  }

  /// Removes the link between [tagID] and [entryID], then refreshes [entries].
  Future<void> removeTag(int entryID, int tagID) async {
    await repository.removeTag(entryID, tagID);
    await loadAll();
  }

  /// Returns the cached list of tag IDs associated with [entry].
  ///
  /// Returns an empty list if no tags have been loaded for this entry.
  List<int> getTags(Journal entry) {
    return _tagCache[entry.id] ?? [];
  }

  /// Replaces all tags on [entry] with [tagIDs].
  ///
  /// Only the diff is applied (adds missing tags, removes stale ones) to
  /// minimise database writes. [entries] is refreshed once after all changes.
  Future<void> setTags(Journal entry, List<int> tagIDs) async {
    List<int> currentTags = getTags(entry);
    final Set<int> currentTagSet = currentTags.toSet();
    final Set<int> tagIdSet = tagIDs.toSet();

    for (int tagID in currentTags) {
      if (!tagIdSet.contains(tagID)) {
        await repository.removeTag(entry.id, tagID);
      }
    }
    for (int tagID in tagIDs) {
      if (!currentTagSet.contains(tagID)) {
        await repository.addTag(entry.id, tagID);
      }
    }
    await loadAll();
  }

  /// Returns the entry with the given [id] directly from the repository.
  Future<Journal> getById(int id) async => repository.getEntry(id);
}
