import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trial_deck.dart';
import '../providers/collection_provider.dart';

/// Widget representing a trial deck in a list.  Shows an image, name,
/// series, quantity and price.  Icons allow wishlisting, editing and
/// deletion.
class DeckItemWidget extends StatelessWidget {
  final TrialDeck deck;
  final VoidCallback? onTap;
  const DeckItemWidget({Key? key, required this.deck, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CollectionProvider>(context, listen: false);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: _buildImage(),
        title: Text(deck.name),
        subtitle: Text(deck.series),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: Icon(deck.wishlisted ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
              onPressed: () async {
                await provider.toggleWishlistForDeck(deck);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Deck'),
                    content: Text('Are you sure you want to delete ${deck.name}?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await provider.deleteDeck(deck.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${deck.name} deleted')),
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

  Widget _buildImage() {
    final path = deck.imageUrl;
    if (path.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 48);
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 48,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
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