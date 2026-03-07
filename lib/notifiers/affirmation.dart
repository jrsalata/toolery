import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:toolery/models/affirmation_item.dart';
import 'package:toolery/models/affirmation_list.dart';
import 'package:toolery/repositories/affirmation.dart';

/// State management for the user's affirmation lists and their items.
///
/// [AffirmationNotifier] extends [ChangeNotifier] and is exposed to the widget
/// tree via `provider`. Widgets consume [lists] and [items] to render content
/// and subscribe to updates via [addListener] / `context.watch`.
///
/// The [items] map is keyed by [AffirmationList.id] and populated lazily as
/// lists are loaded. All mutating methods persist changes through the injected
/// [AffirmationRepository] and then reload the relevant data before notifying
/// listeners.
class AffirmationNotifier extends ChangeNotifier {
  /// The repository used for all affirmation persistence operations.
  final AffirmationRepository repository;

  /// The current list of affirmation collections, refreshed after every
  /// mutation that affects lists.
  List<AffirmationList> lists = [];

  /// A map from [AffirmationList.id] to the items belonging to that list.
  ///
  /// Populated by [loadAll] and updated incrementally by item-level operations.
  Map<int, List<AffirmationItem>> items = {};

  /// Creates an [AffirmationNotifier] and immediately begins loading data from
  /// [repository] once it signals readiness.
  AffirmationNotifier({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    await repository.ready;
    await loadAll();
  }

  /// Fetches all lists and their items from the repository.
  ///
  /// Listeners are notified once loading completes.
  Future<void> loadAll() async {
    lists = await repository.allLists();
    final entries = await Future.wait(
      lists.map((list) async {
        final items = await repository.itemsForList(list.id);
        return MapEntry(list.id, items);
      }),
    );
    items = Map.fromEntries(entries);
    notifyListeners();
  }

  /// Persists [list] to the repository and refreshes [lists].
  Future<void> createList(AffirmationList list) async {
    await repository.insertList(list);
    await loadAll();
  }

  /// Permanently removes the list with [id] and all its items, then refreshes
  /// [lists] and clears the corresponding entry in [items].
  Future<void> deleteList(int id) async {
    await repository.deleteList(id);
    items.remove(id);
    await loadAll();
  }

  /// Overwrites the stored list that matches [list.id] with updated field
  /// values, then refreshes [lists].
  Future<void> updateList(AffirmationList list) async {
    await repository.updateList(list);
    await loadAll();
  }

  /// Reloads items for the list with [listId] from the repository and notifies
  /// listeners.
  Future<void> loadItemsForList(int listId) async {
    items[listId] = await repository.itemsForList(listId);
    notifyListeners();
  }

  /// Persists [item] and refreshes the items for its parent list.
  Future<void> addItem(AffirmationItem item) async {
    await repository.insertItem(item);
    await loadItemsForList(item.listId);
  }

  /// Overwrites the stored item that matches [item.id] with updated field
  /// values, then refreshes the items for its parent list.
  Future<void> updateItem(AffirmationItem item) async {
    await repository.updateItem(item);
    await loadItemsForList(item.listId);
  }

  /// Permanently removes the item with [id] and, if [listId] is provided,
  /// refreshes the items for that list.
  Future<void> deleteItem(int id, {int? listId}) async {
    await repository.deleteItem(id);
    if (listId != null) await loadItemsForList(listId);
  }

  /// Returns a randomly selected affirmation text from the list with [listId].
  ///
  /// If the list has not been loaded yet it is fetched from the repository
  /// first. Returns an empty string if the list has no items.
  Future<String> randomAffirmation(int listId) async {
    var list = items[listId];
    if (list == null) {
      list = await repository.itemsForList(listId);
      items[listId] = list;
      notifyListeners();
    }
    if (list.isEmpty) return '';
    final r = Random();
    final pick = list[r.nextInt(list.length)];
    return pick.item;
  }
}
