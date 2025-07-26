import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../models/ws_card.dart';
import '../models/trial_deck.dart';

/// A utility class responsible for exporting collections or wishlists to PDF.
///
/// The [exportWishlist] method accepts lists of cards and decks and
/// generates a document containing a table of items.  It uses the
/// `printing` package to present a native file save dialog or share sheet.
class PdfExporter {
  PdfExporter._();

  /// Exports the provided [cards] and [decks] into a single PDF document.
  /// If an error occurs during generation or sharing, a snackbar message is
  /// shown.  Images are included if local file paths exist; otherwise the
  /// image column will be empty.
  static Future<void> exportWishlist({
    required BuildContext context,
    required List<WSCard> cards,
    required List<TrialDeck> decks,
  }) async {
    try {
      final pdf = pw.Document();
      final tableHeaders = ['Type', 'Name', 'Qty', 'Price', 'Image'];
      final tableData = <List<pw.Widget>>[];

      // Helper to create an image widget if possible
      Future<pw.Widget> _imageWidget(String path) async {
        if (path.isEmpty) return pw.SizedBox(width: 0, height: 0);
        try {
          final bytes = await File(path).readAsBytes();
          final image = pw.MemoryImage(bytes);
          return pw.Container(
            width: 40,
            height: 60,
            child: pw.Image(image, fit: pw.BoxFit.cover),
          );
        } catch (_) {
          return pw.SizedBox(width: 0, height: 0);
        }
      }

      for (final card in cards) {
        final imgWidget = await _imageWidget(card.imageUrl);
        tableData.add([
          pw.Text('Card'),
          pw.Text(card.name),
          pw.Text(card.quantity.toString()),
          pw.Text(card.price.toStringAsFixed(2)),
          imgWidget,
        ]);
      }
      for (final deck in decks) {
        final imgWidget = await _imageWidget(deck.imageUrl);
        tableData.add([
          pw.Text('Deck'),
          pw.Text(deck.name),
          pw.Text(deck.quantity.toString()),
          pw.Text(deck.price.toStringAsFixed(2)),
          imgWidget,
        ]);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(level: 0, child: pw.Text('Weiß Schwarz Wishlist')),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: const PdfColor(0.9, 0.9, 0.9)),
                    children: tableHeaders.map((e) => pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(e, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    )).toList(),
                  ),
                  ...tableData.map((row) => pw.TableRow(
                        children: row
                            .map((cell) => pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: cell,
                                ))
                            .toList(),
                      )),
                ],
              ),
            ];
          },
        ),
      );
      final bytes = await pdf.save();
      await Printing.sharePdf(bytes: bytes, filename: 'wishlist.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export PDF: $e')),
      );
    }
  }
}