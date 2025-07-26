import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trial_deck.dart';
import '../providers/collection_provider.dart';

/// Screen for adding or editing a trial deck.  Similar to
/// [AddEditCardScreen], but with fields appropriate to decks.
class AddEditTrialDeckScreen extends StatefulWidget {
  final TrialDeck? deck;
  const AddEditTrialDeckScreen({Key? key, this.deck}) : super(key: key);

  @override
  State<AddEditTrialDeckScreen> createState() => _AddEditTrialDeckScreenState();
}

class _AddEditTrialDeckScreenState extends State<AddEditTrialDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _seriesController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    final deck = widget.deck;
    _nameController = TextEditingController(text: deck?.name ?? '');
    _seriesController = TextEditingController(text: deck?.series ?? '');
    _quantityController = TextEditingController(text: deck?.quantity.toString() ?? '1');
    _priceController = TextEditingController(text: deck != null ? deck.price.toStringAsFixed(2) : '0.00');
    _imageUrlController = TextEditingController(text: deck?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seriesController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.deck != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Deck' : 'Add Deck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _seriesController,
                decoration: const InputDecoration(labelText: 'Series'),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter quantity';
                  final q = int.tryParse(value);
                  return q == null || q <= 0 ? 'Invalid quantity' : null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter price';
                  final p = double.tryParse(value);
                  return p == null || p < 0 ? 'Invalid price' : null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL / Path'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final provider = Provider.of<CollectionProvider>(context, listen: false);
                    final quantity = int.parse(_quantityController.text);
                    final price = double.parse(_priceController.text);
                    if (isEditing) {
                      final deck = widget.deck!;
                      deck.name = _nameController.text;
                      deck.series = _seriesController.text;
                      deck.quantity = quantity;
                      deck.price = price;
                      deck.imageUrl = _imageUrlController.text;
                      await provider.updateDeck(deck);
                    } else {
                      final newDeck = TrialDeck(
                        id: 0,
                        name: _nameController.text,
                        series: _seriesController.text,
                        quantity: quantity,
                        price: price,
                        imageUrl: _imageUrlController.text,
                      );
                      await provider.addDeck(newDeck);
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}