import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:toolery/models/affirmation_item.dart';
import 'package:toolery/models/affirmation_list.dart';
import 'package:toolery/repositories/affirmation.dart';

class AffirmationNotifier extends ChangeNotifier {
  final AffirmationRepository repository;
  List<AffirmationList> lists = [];
  Map<int, List<AffirmationItem>> items = {};

  AffirmationNotifier({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    await repository.ready;
    await loadAll();
  }

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

  Future<void> createList(AffirmationList list) async {
    await repository.insertList(list);
    await loadAll();
  }

  Future<void> deleteList(int id) async {
    await repository.deleteList(id);
    items.remove(id);
    await loadAll();
  }

  Future<void> updateList(AffirmationList list) async {
    await repository.updateList(list);
    await loadAll();
  }

  Future<void> loadItemsForList(int listId) async {
    items[listId] = await repository.itemsForList(listId);
    notifyListeners();
  }

  Future<void> addItem(AffirmationItem item) async {
    await repository.insertItem(item);
    await loadItemsForList(item.listId);
  }

  Future<void> updateItem(AffirmationItem item) async {
    await repository.updateItem(item);
    await loadItemsForList(item.listId);
  }

  Future<void> deleteItem(int id, {int? listId}) async {
    await repository.deleteItem(id);
    if (listId != null) await loadItemsForList(listId);
  }

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
