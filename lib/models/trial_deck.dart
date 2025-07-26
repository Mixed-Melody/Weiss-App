import 'dart:io';

import 'package:hive/hive.dart';

/// Represents a trial deck in the Weiß Schwarz trading card game.
///
/// A trial deck is a preconstructed set of cards that can be used right out
/// of the box.  Users can track the number of decks they own, the last
/// observed price and whether they would like to acquire the deck in the
/// future.  Each deck may also maintain a list of owned [WSCard] ids to link
/// cards to decks, but this field is optional and not required for core
/// functionality.
class TrialDeck {
  /// A unique identifier for this deck.  Assigned by the [DatabaseService].
  int id;

  /// The name of the trial deck, usually corresponding to a series or title.
  String name;

  /// The series or franchise this trial deck belongs to (e.g. "Sword Art Online").
  String series;

  /// The number of decks owned by the user.
  int quantity;

  /// The last recorded price of the trial deck.  Updated by the scraper.
  double price;

  /// URL or local file path to an image representing the deck.
  String imageUrl;

  /// List of WSCard ids included in this deck.  Optional; used for future
  /// enhancements where deck composition is tracked.
  List<int> cardIds;

  /// Whether this deck is marked as wanted by the user.
  bool wishlisted;

  TrialDeck({
    required this.id,
    required this.name,
    required this.series,
    this.quantity = 1,
    this.price = 0.0,
    this.imageUrl = '',
    List<int>? cardIds,
    this.wishlisted = false,
  }) : cardIds = cardIds ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'series': series,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'cardIds': cardIds,
      'wishlisted': wishlisted,
    };
  }

  factory TrialDeck.fromMap(Map<String, dynamic> map) {
    return TrialDeck(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      series: map['series'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      cardIds: List<int>.from(map['cardIds'] ?? []),
      wishlisted: map['wishlisted'] ?? false,
    );
  }

  @override
  String toString() => 'TrialDeck(${toMap()})';
}

/// Hive adapter for [TrialDeck].  See [WSCardAdapter] for details on how
/// adapters work.  The [typeId] must be unique across all registered adapters.
class TrialDeckAdapter extends TypeAdapter<TrialDeck> {
  @override
  final int typeId = 1;

  @override
  TrialDeck read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return TrialDeck(
      id: fields[0] as int,
      name: fields[1] as String,
      series: fields[2] as String,
      quantity: fields[3] as int,
      price: fields[4] as double,
      imageUrl: fields[5] as String,
      cardIds: (fields[6] as List).cast<int>(),
      wishlisted: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TrialDeck obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.series)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.cardIds)
      ..writeByte(7)
      ..write(obj.wishlisted);
  }
}