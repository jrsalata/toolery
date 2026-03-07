import 'package:flutter/foundation.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/repositories/breathing.dart';

/// State management for the user's [Breathing] exercise collection.
///
/// [BreathingNotifier] extends [ChangeNotifier] and is exposed to the widget
/// tree via `provider`. Widgets consume [breathings] to render lists and
/// subscribe to updates via [addListener] / `context.watch`.
///
/// All mutating methods persist the change through the injected
/// [BreathingRepository] and then call [loadAll] to refresh [breathings] and
/// notify listeners.
///
/// Tag associations are lazily cached in [_tagCache] to avoid redundant
/// database round-trips on every rebuild.
class BreathingNotifier extends ChangeNotifier {
  /// The repository used for all breathing exercise persistence operations.
  final BreathingRepository repository;

  /// The current list of breathing exercises, refreshed after every mutation.
  List<Breathing> breathings = [];

  // Internal cache mapping breathing id → list of associated tag ids.
  final Map<int, List<int>> _tagCache = {};

  /// Creates a [BreathingNotifier] and immediately begins loading data from
  /// [repository] once it signals readiness.
  BreathingNotifier({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    await repository.ready;
    await loadAll();
  }

  /// Fetches all breathing exercises from the repository and refreshes
  /// [breathings].
  ///
  /// Also repopulates the internal tag cache. Listeners are notified once
  /// loading completes.
  Future<void> loadAll() async {
    breathings = await repository.allBreathing();
    for (Breathing breathing in breathings) {
      _tagCache[breathing.id] = await repository.tagsForBreathing(breathing.id);
    }
    notifyListeners();
  }

  /// Persists [t] and returns the saved copy (with its database-assigned id).
  ///
  /// [breathings] is refreshed and listeners are notified after insertion.
  Future<Breathing> create(Breathing t) async {
    final Breathing created = await repository.insertBreathing(t);
    await loadAll();
    return created;
  }

  /// Permanently removes the breathing exercise with [id] and refreshes
  /// [breathings].
  Future<void> delete(int id) async {
    await repository.deleteBreathing(id);
    await loadAll();
  }

  /// Overwrites the stored exercise that matches [t.id] with updated field
  /// values, then refreshes [breathings].
  Future<void> update(Breathing t) async {
    await repository.updateBreathing(t);
    await loadAll();
  }

  /// Links the tag [tagID] to [breathingID] and refreshes [breathings].
  Future<void> addTag(int breathingID, int tagID) async {
    await repository.addTag(breathingID, tagID);
    await loadAll();
  }

  /// Removes the link between [tagID] and [breathingID], then refreshes
  /// [breathings].
  Future<void> removeTag(int breathingID, int tagID) async {
    await repository.removeTag(breathingID, tagID);
    await loadAll();
  }

  /// Returns the cached list of tag IDs associated with [breathing].
  ///
  /// Returns an empty list if no tags have been loaded for this exercise.
  List<int> getTags(Breathing breathing) {
    return _tagCache[breathing.id] ?? [];
  }

  /// Replaces all tags on [breathing] with [tagIDs].
  ///
  /// Only the diff is applied (adds missing tags, removes stale ones) to
  /// minimise database writes. [breathings] is refreshed once after all changes.
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

  /// Returns the breathing exercise with the given [id] directly from the
  /// repository.
  Future<Breathing> getById(int id) async => repository.getBreathing(id);
}
