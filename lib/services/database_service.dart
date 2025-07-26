// File: lib/services/database_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/ws_card.dart';
import '../models/trial_deck.dart';
import '../models/wishlist_item.dart';

/// A singleton service responsible for managing local data using Hive.
class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  bool _initialized = false;

  late Box<WSCard> _cardsBox;
  late Box<TrialDeck> _decksBox;
  late Box<WishlistItem> _wishlistBox;

  /// Initializes Hive, opens the boxes, and seeds the master catalog.
  Future<void> init() async {
    if (_initialized) return;

    // Ensure Flutter bindings are initialized.
    WidgetsFlutterBinding.ensureInitialized();

    // Pick a directory for Hive data.
    Directory appDir = await getApplicationSupportDirectory();
    Hive.init(appDir.path);

    // Register type adapters.
    Hive.registerAdapter(WSCardAdapter());
    Hive.registerAdapter(TrialDeckAdapter());
    Hive.registerAdapter(WishlistItemAdapter());

    // Open our three boxes.
    _cardsBox     = await Hive.openBox<WSCard>('cards');
    _decksBox     = await Hive.openBox<TrialDeck>('decks');
    _wishlistBox  = await Hive.openBox<WishlistItem>('wishlist');

    _initialized = true;

    await _seedMasterCatalog();

    // -----------------------------------------------------------------
    // Seed the “master catalog” of every card (if not already present)
    // -----------------------------------------------------------------
    await _seedMasterCatalog();
  }

  // -------------------------------------------------------------------------
  // Master‐catalog seeding
  // -------------------------------------------------------------------------

  /// Loads assets/data/cards.json and inserts any missing entries
  /// into the cards box with quantity=0 and wishlisted=false.
  Future<void> _seedMasterCatalog() async {
    final jsonStr = await rootBundle.loadString('assets/data/cards.json');
    final List<dynamic> rawList = json.decode(jsonStr);

    for (var entry in rawList) {
      final int masterId = entry['id'] as int;
      if (_cardsBox.containsKey(masterId)) continue;

      final card = WSCard(
        id:         masterId,
        name:       entry['name']    as String,
        setName:    entry['set']     as String,
        rarity:     (entry['rarity'] as String?) ?? 'Unknown', // ← default
        color:      (entry['color']     as String?) ?? 'Colorless',
        cardNumber: (entry['cardNumber']as String?) ?? '',
        quantity:   0,
        price:      (entry['price'] as num).toDouble(),
        imageUrl:   entry['imageUrl'] as String,
        wishlisted: false,
      );

      await _cardsBox.put(masterId, card);
    }
  }

  // -------------------------------------------------------------------------
  // Card operations
  // -------------------------------------------------------------------------

  List<WSCard> getCards() => _cardsBox.values.toList();

  Future<void> addCard(WSCard card) async {
    int id = _cardsBox.isEmpty
      ? 0
      : (_cardsBox.keys.cast<int>().reduce((a,b) => a>b ? a : b) + 1);
    card.id = id;
    await _cardsBox.put(id, card);
  }

  Future<void> updateCard(WSCard card) async {
    if (!_cardsBox.containsKey(card.id)) {
      throw Exception('No card with id ${card.id}');
    }
    await _cardsBox.put(card.id, card);
  }

  Future<void> deleteCard(int id) async {
    // Clean up any wishlist entries for this card
    final toRemove = _wishlistBox.values
      .where((w) => w.itemType=='card' && w.itemId==id)
      .toList();
    for (var w in toRemove) {
      await _wishlistBox.delete(w.id);
    }
    await _cardsBox.delete(id);
  }

  // -------------------------------------------------------------------------
  // Deck operations
  // -------------------------------------------------------------------------

  List<TrialDeck> getDecks() => _decksBox.values.toList();

  Future<void> addDeck(TrialDeck deck) async {
    int id = _decksBox.isEmpty
      ? 0
      : (_decksBox.keys.cast<int>().reduce((a,b) => a>b ? a : b) + 1);
    deck.id = id;
    await _decksBox.put(id, deck);
  }

  Future<void> updateDeck(TrialDeck deck) async {
    if (!_decksBox.containsKey(deck.id)) {
      throw Exception('No deck with id ${deck.id}');
    }
    await _decksBox.put(deck.id, deck);
  }

  Future<void> deleteDeck(int id) async {
    final toRemove = _wishlistBox.values
      .where((w) => w.itemType=='deck' && w.itemId==id)
      .toList();
    for (var w in toRemove) {
      await _wishlistBox.delete(w.id);
    }
    await _decksBox.delete(id);
  }

  // -------------------------------------------------------------------------
  // Wishlist operations
  // -------------------------------------------------------------------------

  List<WishlistItem> getWishlist() => _wishlistBox.values.toList();

  Future<void> addWishlistItem(WishlistItem item) async {
    int id = _wishlistBox.isEmpty
      ? 0
      : (_wishlistBox.keys.cast<int>().reduce((a,b) => a>b ? a : b) + 1);
    item.id = id;
    await _wishlistBox.put(id, item);
  }

  Future<void> removeWishlistItem(int id) async {
    await _wishlistBox.delete(id);
  }

  Future<void> toggleWishlistForCard(WSCard card) async {
    card.wishlisted = !card.wishlisted;
    await updateCard(card);
    if (card.wishlisted) {
      await addWishlistItem(
        WishlistItem(id: 0, itemType: 'card', itemId: card.id),
      );
    } else {
      final toRemove = _wishlistBox.values
        .where((w) => w.itemType=='card' && w.itemId==card.id)
        .toList();
      for (var w in toRemove) {
        await removeWishlistItem(w.id);
      }
    }
  }

  Future<void> toggleWishlistForDeck(TrialDeck deck) async {
    deck.wishlisted = !deck.wishlisted;
    await updateDeck(deck);
    if (deck.wishlisted) {
      await addWishlistItem(
        WishlistItem(id: 0, itemType: 'deck', itemId: deck.id),
      );
    } else {
      final toRemove = _wishlistBox.values
        .where((w) => w.itemType=='deck' && w.itemId==deck.id)
        .toList();
      for (var w in toRemove) {
        await removeWishlistItem(w.id);
      }
    }
  }
}
