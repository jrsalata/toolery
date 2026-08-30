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
  /// If [tagIDs] is given, those tags are attached before the reload, so
  /// creation and tagging land in a single [loadAll]/notifyListeners cycle
  /// instead of two separate ones (which left a gap a slow test environment
  /// could observe as "settled" mid-save — see [setTags]).
  Future<Journal> create(Journal entry, {List<int>? tagIDs}) async {
    final Journal created = await repository.insertEntry(entry);
    if (tagIDs != null && tagIDs.isNotEmpty) {
      await _applyTagDiff(created.id, const <int>[], tagIDs);
    }
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
  ///
  /// If [tagIDs] is given, tags are diffed against the current set and
  /// applied before the same reload (see [create] for why this matters).
  Future<void> update(Journal entry, {List<int>? tagIDs}) async {
    await repository.updateEntry(entry);
    if (tagIDs != null) {
      await _applyTagDiff(entry.id, getTags(entry), tagIDs);
    }
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
    await _applyTagDiff(entry.id, getTags(entry), tagIDs);
    await loadAll();
  }

  /// Applies the add/remove calls needed to take [entryID] from [currentTags]
  /// to [tagIDs], without reloading. Callers reload once, after their own
  /// entity write, so a save that touches both the entity and its tags
  /// produces a single notifyListeners cycle instead of two.
  Future<void> _applyTagDiff(
    int entryID,
    List<int> currentTags,
    List<int> tagIDs,
  ) async {
    final Set<int> currentTagSet = currentTags.toSet();
    final Set<int> tagIdSet = tagIDs.toSet();

    for (int tagID in currentTags) {
      if (!tagIdSet.contains(tagID)) {
        await repository.removeTag(entryID, tagID);
      }
    }
    for (int tagID in tagIDs) {
      if (!currentTagSet.contains(tagID)) {
        await repository.addTag(entryID, tagID);
      }
    }
  }

  /// Returns the entry with the given [id] directly from the repository.
  Future<Journal> getById(int id) async => repository.getEntry(id);
}
