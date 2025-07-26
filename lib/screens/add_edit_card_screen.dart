import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ws_card.dart';
import '../providers/collection_provider.dart';

/// Screen for adding a new card or editing an existing one.  Uses a
/// [Form] with basic validation.  The [WSCard] parameter is optional; when
/// present the fields are pre-filled and saving will update the existing
/// record.  When absent, saving will create a new record.
class AddEditCardScreen extends StatefulWidget {
  final WSCard? card;
  const AddEditCardScreen({Key? key, this.card}) : super(key: key);

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _setController;
  late final TextEditingController _rarityController;
  late final TextEditingController _colorController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    final card = widget.card;
    _nameController = TextEditingController(text: card?.name ?? '');
    _setController = TextEditingController(text: card?.setName ?? '');
    _rarityController = TextEditingController(text: card?.rarity ?? '');
    _colorController = TextEditingController(text: card?.color ?? '');
    _cardNumberController = TextEditingController(text: card?.cardNumber ?? '');
    _quantityController = TextEditingController(text: card?.quantity.toString() ?? '1');
    _priceController = TextEditingController(text: card != null ? card.price.toStringAsFixed(2) : '0.00');
    _imageUrlController = TextEditingController(text: card?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setController.dispose();
    _rarityController.dispose();
    _colorController.dispose();
    _cardNumberController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.card != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Card' : 'Add Card'),
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
                controller: _setController,
                decoration: const InputDecoration(labelText: 'Set'),
              ),
              TextFormField(
                controller: _rarityController,
                decoration: const InputDecoration(labelText: 'Rarity'),
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
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
                      final card = widget.card!;
                      card.name = _nameController.text;
                      card.setName = _setController.text;
                      card.rarity = _rarityController.text;
                      card.color = _colorController.text;
                      card.cardNumber = _cardNumberController.text;
                      card.quantity = quantity;
                      card.price = price;
                      card.imageUrl = _imageUrlController.text;
                      await provider.updateCard(card);
                    } else {
                      final newCard = WSCard(
                        id: 0,
                        name: _nameController.text,
                        setName: _setController.text,
                        rarity: _rarityController.text,
                        color: _colorController.text,
                        cardNumber: _cardNumberController.text,
                        quantity: quantity,
                        price: price,
                        imageUrl: _imageUrlController.text,
                      );
                      await provider.addCard(newCard);
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