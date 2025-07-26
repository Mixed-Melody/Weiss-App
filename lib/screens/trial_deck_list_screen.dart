import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/collection_provider.dart';
import '../widgets/deck_item_widget.dart';
import 'add_edit_trial_deck_screen.dart';

/// Displays the list of trial decks in the user's collection.  Provides
/// facilities for adding, editing and deleting decks, as well as toggling
/// wishlist status.
class TrialDeckListScreen extends StatelessWidget {
  const TrialDeckListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionProvider>(
      builder: (context, provider, child) {
        final decks = provider.decks;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Trial Decks'),
          ),
          body: decks.isEmpty
              ? const Center(child: Text('No trial decks added yet.'))
              : ListView.builder(
                  itemCount: decks.length,
                  itemBuilder: (context, index) {
                    final deck = decks[index];
                    return DeckItemWidget(
                      deck: deck,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditTrialDeckScreen(deck: deck),
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
                  builder: (context) => const AddEditTrialDeckScreen(),
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