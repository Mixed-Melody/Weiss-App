import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ws_card.dart';
import '../providers/collection_provider.dart';
import '../widgets/card_item_widget.dart';
import 'add_edit_card_screen.dart';

/// Displays all cards in the user's collection.  Allows editing,
/// deletion and toggling wishlist state.  A floating action button lets the
/// user add new cards.
class CardListScreen extends StatelessWidget {
  const CardListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionProvider>(
      builder: (context, provider, child) {
        final cards = provider.cards;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cards'),
          ),
          body: cards.isEmpty
              ? const Center(child: Text('No cards added yet.'))
              : ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return WSCardItemWidget(
                      card: card,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditCardScreen(card: card),
                          ),
                        );
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditCardScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}