import 'package:hive/hive.dart';

/// An item in the user's wishlist.  A wishlist entry refers either to a
/// [WSCard] or a [TrialDeck], identified by [itemId] and [itemType].
/// Keeping a separate model simplifies persistence and allows the
/// wishlist to store lightweight references rather than full item objects.
class WishlistItem {
  /// Unique identifier for this wishlist entry.  Assigned by the
  /// [DatabaseService].
  int id;

  /// The type of the item: either 'card' or 'deck'.  Consider using an enum
  /// instead of a string for stronger typing in future revisions.
  String itemType;

  /// The id of the referenced card or trial deck in its respective Hive box.
  int itemId;

  WishlistItem({required this.id, required this.itemType, required this.itemId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemType': itemType,
      'itemId': itemId,
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] ?? 0,
      itemType: map['itemType'] ?? '',
      itemId: map['itemId'] ?? 0,
    );
  }

  @override
  String toString() => 'WishlistItem(${toMap()})';
}

/// Hive adapter for [WishlistItem].  Uses a unique [typeId] distinct from
/// other adapters in this project.  Avoid changing the [typeId] once data has
/// been stored or you risk corrupting existing user data.
class WishlistItemAdapter extends TypeAdapter<WishlistItem> {
  @override
  final int typeId = 2;

  @override
  WishlistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return WishlistItem(
      id: fields[0] as int,
      itemType: fields[1] as String,
      itemId: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WishlistItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemType)
      ..writeByte(2)
      ..write(obj.itemId);
  }
}