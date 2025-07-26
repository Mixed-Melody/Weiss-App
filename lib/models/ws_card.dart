import 'dart:io';

import 'package:hive/hive.dart';

/// Represents an individual Weiß Schwarz trading card owned by the user.
///
/// This model is stored in a Hive box to persist the user's collection across
/// app launches.  Fields include identifying information about the card,
/// quantity owned, last known price and a local or remote image URL.  The
/// [wishlisted] flag indicates whether the card appears in the user's
/// wishlist.  See [DatabaseService] for persistence logic.
class WSCard {
  /// A unique identifier for this card.  It is assigned by the
  /// [DatabaseService] when the card is added to the database.  The id
  /// corresponds to the key within the Hive box.
  int id;

  /// The display name of the card.  This usually corresponds to the card's
  /// official title in the Weiß Schwarz trading card game.
  String name;

  /// The name of the set the card belongs to (e.g. "Attack on Titan", "Fate/Stay Night").
  String setName;

  /// The rarity of the card (e.g. C, R, SR, RR).  Rarity can affect price.
  String rarity;

  /// The color of the card (e.g. Yellow, Green, Red, Blue).  Colors are used
  /// by the game mechanics and make interesting chart categories on the dashboard.
  String color;

  /// The unique card number printed on the card (e.g. "AOT/S35-045").
  String cardNumber;

  /// The number of copies of this card owned by the user.
  int quantity;

  /// The last recorded unit price for this card.  When the price scraper
  /// updates the value, this field is overwritten.  A value of zero means
  /// that the price has not yet been set.
  double price;

  /// A URL or local file system path to an image representing the card.  The
  /// scraper may download the image and store it locally; otherwise a network
  /// URL may be used.  If empty, a placeholder image will be shown.
  String imageUrl;

  /// Whether this card is marked as wanted by the user.  When true the
  /// corresponding [WishlistItem] record exists in the wishlist box.
  bool wishlisted;

  WSCard({
    required this.id,
    required this.name,
    required this.setName,
    required this.rarity,
    required this.color,
    required this.cardNumber,
    this.quantity = 1,
    this.price = 0.0,
    this.imageUrl = '',
    this.wishlisted = false,
  });

  /// Converts this card into a map for easy serialization or debugging.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'setName': setName,
      'rarity': rarity,
      'color': color,
      'cardNumber': cardNumber,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'wishlisted': wishlisted,
    };
  }

  /// Constructs a [WSCard] from a map.  If a field is missing it will be
  /// initialized with a sensible default.
  factory WSCard.fromMap(Map<String, dynamic> map) {
    return WSCard(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      setName: map['setName'] ?? '',
      rarity: map['rarity'] ?? '',
      color: map['color'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      wishlisted: map['wishlisted'] ?? false,
    );
  }

  @override
  String toString() => 'WSCard(${toMap()})';
}

/// A Hive adapter for serializing and deserializing [WSCard] objects.
///
/// Hive requires a unique [typeId] for each registered adapter.  Do not
/// change the typeId once it has been used to store data, otherwise
/// previously stored records will fail to deserialize.
class WSCardAdapter extends TypeAdapter<WSCard> {
  @override
  final int typeId = 0;

  @override
  WSCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final int field = reader.readByte();
      fields[field] = reader.read();
    }
    return WSCard(
      id: fields[0] as int,
      name: fields[1] as String,
      setName: fields[2] as String,
      rarity: fields[3] as String,
      color: fields[4] as String,
      cardNumber: fields[5] as String,
      quantity: fields[6] as int,
      price: fields[7] as double,
      imageUrl: fields[8] as String,
      wishlisted: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WSCard obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.setName)
      ..writeByte(3)
      ..write(obj.rarity)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.cardNumber)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.price)
      ..writeByte(8)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.wishlisted);
  }
}