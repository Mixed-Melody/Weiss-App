import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ws_card.dart';
import '../models/trial_deck.dart';
import '../providers/collection_provider.dart';
import '../services/pdf_exporter.dart';

/// Displays all items that the user has marked as wishlisted.  Allows the
/// user to select multiple items and export them to a PDF document.  The
/// selection state is managed locally within this widget.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final Map<String, bool> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionProvider>(
      builder: (context, provider, child) {
        final cards = provider.cards.where((c) => c.wishlisted).toList();
        final decks = provider.decks.where((d) => d.wishlisted).toList();
        final bool hasItems = cards.isNotEmpty || decks.isNotEmpty;

        // Initialize selection map for new items
        for (final c in cards) {
          _selected.putIfAbsent('card_${c.id}', () => false);
        }
        for (final d in decks) {
          _selected.putIfAbsent('deck_${d.id}', () => false);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Wishlist'),
          ),
          body: !hasItems
              ? const Center(child: Text('Your wishlist is empty.'))
              : ListView(
                  children: [
                    ...cards.map((card) => CheckboxListTile(
                          title: Text(card.name),
                          subtitle: Text('${card.setName} • ${card.cardNumber}'),
                          value: _selected['card_${card.id}'],
                          onChanged: (bool? value) {
                            setState(() {
                              _selected['card_${card.id}'] = value ?? false;
                            });
                          },
                          secondary: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.redAccent),
                            onPressed: () async {
                              await provider.toggleWishlistForCard(card);
                            },
                          ),
                        )),
                    ...decks.map((deck) => CheckboxListTile(
                          title: Text(deck.name),
                          subtitle: Text(deck.series),
                          value: _selected['deck_${deck.id}'],
                          onChanged: (bool? value) {
                            setState(() {
                              _selected['deck_${deck.id}'] = value ?? false;
                            });
                          },
                          secondary: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.redAccent),
                            onPressed: () async {
                              await provider.toggleWishlistForDeck(deck);
                            },
                          ),
                        )),
                    const SizedBox(height: 16),
                    if (hasItems)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final selectedCards = <WSCard>[];
                            final selectedDecks = <TrialDeck>[];
                            WSCard? _findCard(int id) {
                              for (final c in cards) {
                                if (c.id == id) return c;
                              }
                              return null;
                            }
                            TrialDeck? _findDeck(int id) {
                              for (final d in decks) {
                                if (d.id == id) return d;
                              }
                              return null;
                            }
                            for (final entry in _selected.entries) {
                              if (entry.value) {
                                if (entry.key.startsWith('card_')) {
                                  final id = int.parse(entry.key.substring(5));
                                  final card = _findCard(id);
                                  if (card != null) selectedCards.add(card);
                                } else if (entry.key.startsWith('deck_')) {
                                  final id = int.parse(entry.key.substring(5));
                                  final deck = _findDeck(id);
                                  if (deck != null) selectedDecks.add(deck);
                                }
                              }
                            }
                            if (selectedCards.isEmpty && selectedDecks.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No items selected for export.')),
                              );
                              return;
                            }
                            await PdfExporter.exportWishlist(
                              context: context,
                              cards: selectedCards,
                              decks: selectedDecks,
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Export Selected to PDF'),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
        );
      },
    );
  }
}