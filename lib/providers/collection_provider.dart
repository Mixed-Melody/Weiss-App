import 'package:flutter/foundation.dart';

import '../models/ws_card.dart';
import '../models/trial_deck.dart';
import '../models/wishlist_item.dart';
import '../services/database_service.dart';

/// A [ChangeNotifier] that exposes the user's collection of cards, trial decks
/// and wishlist items to the UI.  This provider wraps [DatabaseService]
/// methods and emits notifications whenever the underlying data changes.  UI
/// widgets can listen to this provider to update automatically.
class CollectionProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<WSCard> _cards = [];
  List<TrialDeck> _decks = [];
  List<WishlistItem> _wishlist = [];

  /// Read-only view of the cards list.
  List<WSCard> get cards => List.unmodifiable(_cards);
  /// Read-only view of the trial decks list.
  List<TrialDeck> get decks => List.unmodifiable(_decks);
  /// Read-only view of the wishlist.
  List<WishlistItem> get wishlist => List.unmodifiable(_wishlist);

  CollectionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _db.init();
    await reloadAll();
  }

  /// Reloads cards, decks and wishlist from the database.
  Future<void> reloadAll() async {
    _cards = _db.getCards();
    _decks = _db.getDecks();
    _wishlist = _db.getWishlist();
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // Card operations
  //

  Future<void> addCard(WSCard card) async {
    await _db.addCard(card);
    await reloadAll();
  }

  Future<void> updateCard(WSCard card) async {
    await _db.updateCard(card);
    await reloadAll();
  }

  Future<void> deleteCard(int id) async {
    await _db.deleteCard(id);
    await reloadAll();
  }

  Future<void> toggleWishlistForCard(WSCard card) async {
    await _db.toggleWishlistForCard(card);
    await reloadAll();
  }

  // -------------------------------------------------------------------------
  // Deck operations
  //

  Future<void> addDeck(TrialDeck deck) async {
    await _db.addDeck(deck);
    await reloadAll();
  }

  Future<void> updateDeck(TrialDeck deck) async {
    await _db.updateDeck(deck);
    await reloadAll();
  }

  Future<void> deleteDeck(int id) async {
    await _db.deleteDeck(id);
    await reloadAll();
  }

  Future<void> toggleWishlistForDeck(TrialDeck deck) async {
    await _db.toggleWishlistForDeck(deck);
    await reloadAll();
  }

  // -------------------------------------------------------------------------
  // Derived values
  //

  /// Returns the total value of the collection, computed as the sum of
  /// `price * quantity` for all cards and trial decks.
  double get totalValue {
    double total = 0;
    for (final card in _cards) {
      total += card.price * card.quantity;
    }
    for (final deck in _decks) {
      total += deck.price * deck.quantity;
    }
    return total;
  }

  /// Computes the number of wishlisted items (both cards and decks).
  int get wishlistedCount => _cards.where((c) => c.wishlisted).length + _decks.where((d) => d.wishlisted).length;

  /// Group cards by color and return a map of color to count.  Used by the
  /// dashboard to draw pie charts.  If no cards exist the map will be empty.
  Map<String, int> get colorDistribution {
    final Map<String, int> dist = {};
    for (final card in _cards) {
      dist[card.color] = (dist[card.color] ?? 0) + card.quantity;
    }
    return dist;
  }
}