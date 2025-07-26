import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ws_card.dart';
import '../providers/collection_provider.dart';

/// A widget representing a single card in a list.  It displays the card's
/// image, name, set, rarity, quantity and price.  Buttons allow the user
/// to toggle wishlist status, edit the card or delete it from the collection.
class WSCardItemWidget extends StatelessWidget {
  final WSCard card;
  final VoidCallback? onTap;
  const WSCardItemWidget({Key? key, required this.card, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CollectionProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: theme.cardColor,  // will be dark
      child: ListTile(
        leading: _buildImage(),
        title: Text(
          card.name,
          style: theme.textTheme.labelSmall,
        ),
        subtitle: Text(
          '${card.setName} • ${card.rarity}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            // Wishlist heart: orangeAccent when on, grey when off
            IconButton(
              icon: Icon(
                card.wishlisted ? Icons.favorite : Icons.favorite_border,
              ),
              color: card.wishlisted
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onBackground,
              onPressed: () async {
                await provider.toggleWishlistForCard(card);
              },
            ),

            // Edit button: primary accent
            IconButton(
              icon: const Icon(Icons.edit),
              color: theme.colorScheme.primary,
              onPressed: onTap,
            ),

            // Delete button: use error color for dangerous action
            IconButton(
              icon: const Icon(Icons.delete),
              color: theme.colorScheme.error,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Card'),
                    content: Text('Are you sure you want to delete ${card.name}?'),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: theme.colorScheme.onBackground,
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await provider.deleteCard(card.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${card.name} deleted')),
                  );
                }
              },
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  /// Returns a widget for the card image.  Uses a local file if the
  /// [imageUrl] is a valid path; otherwise attempts to load it from the
  /// network.  If both fail a placeholder icon is shown.
  Widget _buildImage() {
    final path = card.imageUrl;
    if (path.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 48);
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 48,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 48),
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 48,
        height: 72,
        fit: BoxFit.cover,
      );
    }
    return const Icon(Icons.image_not_supported, size: 48);
  }
}
